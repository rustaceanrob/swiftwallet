//
//  LightningWallet.swift
//  Magma
//
//  Created by Robert Netzke on 1/8/24.
//

import Foundation
import BreezSDK

enum LightningError: Error {
    case InvalidSeed
}

class SDKListener: EventListener, ObservableObject {
    
    @Published var nextEvent: String
    
    init() {
        self.nextEvent = ""
    }

    func onEvent(e: BreezEvent) {
        dump(e)
        let repr = String(reflecting: e)
        DispatchQueue.main.async {
            self.nextEvent = repr
        }
    }
}

struct FeeDigest {
    var urgent: (UInt64, Float)
    var halfHour: (UInt64, Float)
    var hour: (UInt64, Float)
    var economy: (UInt64, Float)
}

final class LightningWallet {
    static let shared = LightningWallet()
    private let converter = Converter()
    private var sdk: BlockingBreezServices?
    private var exchangeRate: Float?
    private var pendingAddressOrInvoice: String?
    private var pendingPaymentDescription: String?
    private var pendingInvoiceFiatAmount: Float?
    private var pendingInvoiceBitcoinAmount: Float?
    private var pendingPaymentHash: String?
    private var pendingLnUrlData: LnUrlPayRequestData?
    
    let listener: SDKListener
    var inboundLiquidity: Float?
    var balance: Float?
    var estimatedFees: FeeDigest?
    var txs: [TransactionListItemModel] = []
    
    var breezSdkDirectory: URL {
        let applicationDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let breezSdkDirectory = applicationDirectory.appendingPathComponent("breezSdk", isDirectory: true)
        if !FileManager.default.fileExists(atPath: breezSdkDirectory.path) {
            try! FileManager.default.createDirectory(atPath: breezSdkDirectory.path, withIntermediateDirectories: true)
        }
        return breezSdkDirectory
    }
    
    init() {
        self.listener = SDKListener()
    }
    
    func startServices(mnemonic: String) throws {
        let seed = try? mnemonicToSeed(phrase: mnemonic)
        if let seed = seed {
            let config = getConfig()
            self.sdk = try connect(config: config, seed: seed, listener: self.listener)
            print("Connected")
        } else {
            throw LightningError.InvalidSeed
        }
    }
    
    func refresh() {
        print("Refreshing")
        walletDigest()
        print("Updated")
    }
    
    private func getConfig() -> Config {
        let inviteCode = ProcessInfo.processInfo.environment["INVITE"]!
        let apiKey = ProcessInfo.processInfo.environment["BREEZ_API"]!
        var config = defaultConfig(envType: EnvironmentType.production, apiKey: apiKey,
            nodeConfig: NodeConfig.greenlight(
                config: GreenlightNodeConfig(partnerCredentials: nil, inviteCode: inviteCode)))
        config.workingDir = breezSdkDirectory.absoluteString
        return config
    }
    
    func getExchangeRate(fiat: String) throws -> Float? {
        var exchange: Float? = nil
        let rates = try? sdk?.fetchFiatRates()
        if let rates = rates {
            print("Fetching current exchange rate")
            rates.forEach({ rate in
                if rate.coin == fiat { exchange = Float(rate.value) }
            })
        }
        self.exchangeRate = exchange
        return exchange
    }
    
    private func walletDigest() {
        let info = try? sdk?.nodeInfo()
        print("SDK connected")
        if let info = info {
            self.balance = (Float(info.channelsBalanceMsat) / 1_000.00) + (Float(info.onchainBalanceMsat) / 1_000.00)
            self.inboundLiquidity = Float(info.inboundLiquidityMsats) / 1_000.00
            print("Updating balance and liquidity")
        }
        
        let payments = try? sdk?.listPayments(req: ListPaymentsRequest())
        if let payments = payments {
            print("Updating payments")
            var temp: [TransactionListItemModel] = []
            for payment in payments {
                let btc = converter.msatToBtc(msat: payment.amountMsat)
                
                let breezPayment = payment.paymentType
                var wasSent = true
                if breezPayment == .received {
                    wasSent = false
                }
                let breezStatus = payment.status
                var wasConfirmed = true
                if breezStatus == .pending {
                    wasConfirmed = false
                }
                let time = UInt64(payment.paymentTime)
                var fiatAmount: Float? = nil
                if let exchange = self.exchangeRate {
                    fiatAmount = btc * exchange
                }
                temp.append(TransactionListItemModel(id: payment.id, amount: btc, wasSent: wasSent, wasConfirmed: wasConfirmed, onChain: false, detail: payment.description ?? "", fiatAmount: fiatAmount, time: time))
            }
            print("Setting payment history")
            self.txs = temp
        }
        self.estimatedFees = getFeeDigest()
    }
    
    func lnInvoiceFromFiat(fiat: Float, exchange: Float, description: String) -> LnInvoiceRequestModel? {
        let sats = self.converter.fiatToSats(exchangeRate: exchange, fiat: fiat)
        if let sdk = self.sdk {
            print("SDK connected")
            let receivePaymentResponse = try? sdk.receivePayment(
                req: ReceivePaymentRequest(
                    amountMsat: sats * 1_000,
                    description: description))
            let invoice = receivePaymentResponse?.lnInvoice
            let fee = receivePaymentResponse?.openingFeeMsat
            if let invoice = invoice {
                if let fee = fee {
                    print("Some fee to receive the transaction.")
                    let sats = UInt64(self.converter.msatToSat(msats: fee))
                    let fiatFee = self.converter.satsToFiat(sats: sats, exchangeRate: exchange)
                    return LnInvoiceRequestModel(bolt11: invoice.bolt11, feeInFiat: fiatFee)
                } else {
                    print("No fee to receive the transaction.")
                    return LnInvoiceRequestModel(bolt11: invoice.bolt11)
                }
            } else {
                return nil
            }
        }
        print("Could not fetch invoice")
        return nil
    }
    
    func parseUserInput(userInput: String) async -> SendProgressType {
        let parsed = try? parseInput(s: userInput)
        if let parsed = parsed {
            if case .bitcoinAddress(let bip21) = parsed {
                self.pendingAddressOrInvoice = bip21.address
                self.pendingPaymentDescription = bip21.message
                handleOptionalParsedAmount(amountMsat: bip21.amountSat)
                return .bitcoin
            }
            if case .bolt11(let invoice) = parsed {
                self.pendingAddressOrInvoice = invoice.bolt11
                self.pendingPaymentDescription = invoice.description
                handleOptionalParsedAmount(amountMsat: invoice.amountMsat)
                self.pendingPaymentHash = invoice.paymentHash
                return .lnInvoice
            }
            if case .lnUrlPay(let data) = parsed {
                self.pendingLnUrlData = data
                if let url = data.lnAddress {
                    self.pendingAddressOrInvoice = url
                }
                return .lnUrl
            }
            if case.nodeId(let nodeId) = parsed {
                self.pendingAddressOrInvoice = nodeId
                return .keysend
            }
        }
        print("Could not parse input")
        return .none
    }
    
    private func handleOptionalParsedAmount(amountMsat: UInt64?) {
        if let amount = amountMsat {
            print(amount)
            let satsAmount = UInt64(self.converter.msatToSat(msats: amount))
            self.pendingInvoiceBitcoinAmount = self.converter.satsToBtc(sats: satsAmount)
            if let exchange = self.exchangeRate {
                self.pendingInvoiceFiatAmount = self.converter.satsToFiat(sats: satsAmount, exchangeRate: exchange)
            }
        }
    }
    
    func fetchPendingPayment() -> (String?, String?, Float?, Float?) {
        (self.pendingAddressOrInvoice, self.pendingPaymentDescription, self.pendingInvoiceFiatAmount, self.pendingInvoiceBitcoinAmount)
    }
    
    func sendLightningInvoicePayment(fiatAmount: Float?, paymentType: SendProgressType, userDescription: String?) async {
        switch paymentType {
        case .keysend:
            if let amount = fiatAmount {
                if let exchange = self.exchangeRate {
                    let mSats = converter.fiatToMsats(exchangeRate: exchange, fiat: amount)
                    let req = SendSpontaneousPaymentRequest(nodeId: self.pendingAddressOrInvoice!, amountMsat: mSats)
                    let _ = try? sdk?.sendSpontaneousPayment(req: req)
                }
            }
        case .lnInvoice:
            if let amount = fiatAmount {
                if let exchange = self.exchangeRate {
                    let mSats = converter.fiatToMsats(exchangeRate: exchange, fiat: amount)
                    let sendReq = SendPaymentRequest(bolt11: self.pendingAddressOrInvoice!, amountMsat: mSats)
                    let _ = try? sdk?.sendPayment(req: sendReq)
                }
            } else {
                let sendReq = SendPaymentRequest(bolt11: self.pendingAddressOrInvoice!)
                let _ = try? sdk?.sendPayment(req: sendReq)
            }
        case .bitcoin:
            return
        case .lnUrl:
            if let amount = fiatAmount {
                if let exchange = self.exchangeRate {
                    let mSats = converter.fiatToMsats(exchangeRate: exchange, fiat: amount)
                    let _ = try? sdk?.payLnurl(req: LnUrlPayRequest(data: self.pendingLnUrlData!, amountMsat: mSats, comment: userDescription ?? ""))
                }
            }
        case .none:
            return
        case .successful:
            return
        case .failed:
            return
        }
    }
    
    func getLnUrlMin() -> Float? {
        if let min = self.pendingLnUrlData?.minSendable {
            let minSats = self.converter.msatToSat(msats: min)
            if let exchange = self.exchangeRate {
                let minFiat = self.converter.satsToFiat(sats: UInt64(minSats), exchangeRate: exchange)
                return minFiat
            }
        }
        return nil
    }
    
    func reportRouteFailure() async {
        if let hash = self.pendingPaymentHash {
            try? sdk?.reportIssue(req: ReportIssueRequest.paymentFailure(data: ReportPaymentFailureDetails(paymentHash: hash)))
        }
    }
    
    func getNodeInfo() -> NodeInfoModel? {
        let info = try? sdk?.nodeInfo()
        if let info = info {
            let height = info.blockHeight
            let inboundLiq = info.inboundLiquidityMsats
            let nodeId = info.id
            let maxAmountPayable = info.maxPayableMsat
            let maxAmountReceivable = info.maxReceivableMsat
            let peers = info.connectedPeers
            return NodeInfoModel(height: height, inboundLiq: inboundLiq, nodeId: nodeId, maxAmountPayable: maxAmountPayable, maxAmountReceivable: maxAmountReceivable, peers: peers)
        } else {
            return nil
        }
    }
    
    func getFeeDigest() -> FeeDigest? {        
        let fees = try? sdk?.recommendedFees()
        if let fees = fees {
            if let exchange = self.exchangeRate {
                return FeeDigest(urgent: self.converter.satVbToFiat(satVb: fees.fastestFee, exchangeRate: exchange),
                                 halfHour: self.converter.satVbToFiat(satVb: fees.halfHourFee, exchangeRate: exchange),
                                 hour: self.converter.satVbToFiat(satVb: fees.hourFee, exchangeRate: exchange),
                                 economy: self.converter.satVbToFiat(satVb: fees.economyFee, exchangeRate: exchange))
            } else {
                return nil
            }
        }
        return nil
    }
    
    
}
