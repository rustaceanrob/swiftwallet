//
//  BitcoinWallet.swift
//  Magma
//
//  Created by Robert Netzke on 12/20/23.
//

import Foundation
import BitcoinDevKit

enum PaymentStatus {
    case succeed
    case fail
    case pending
}

final class BitcoinWallet: ObservableObject {
    @Published var broadcastPayment: PaymentStatus = .pending
    
    static let shared = BitcoinWallet()
    private var wallet: Wallet?
    private var blockchain: Blockchain?
    private let converter = Converter()
    
    var txs: [TransactionListItemModel]
    var balance: UInt64?
    var receiveAddress: String?
    
    var bdkUrl: URL {
        let applicationDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = applicationDirectory.appendingPathComponent("bdkWallet", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try! FileManager.default.createDirectory(atPath: dir.path, withIntermediateDirectories: true)
        }
        return dir
    }
    
    init() {
        let esplora = EsploraConfig(baseUrl: "https://blockstream.info/api/", proxy: nil, concurrency: 8, stopGap: 2, timeout: 15)
        let blockchainConfig = BlockchainConfig.esplora(config: esplora)
        self.blockchain = try? Blockchain(config: blockchainConfig)
        self.txs = []
    }
    
    func intializeWorker(mnemonic: String) throws {
        let receive = try makeDescriptor(mnemonic: mnemonic, isChange: false)
        let change = try makeDescriptor(mnemonic: mnemonic, isChange: true)
        let sled = DatabaseConfig.sled(config: SledDbConfiguration(path: bdkUrl.relativePath, treeName: "bdk"))
        let wallet = try Wallet(descriptor: receive, changeDescriptor: change, network: Network.bitcoin, databaseConfig: sled)
        self.wallet = wallet
        self.balance = self.getBalance()
        self.receiveAddress = self.nextAddress()
        self.listTxs()
    }
    
    func mnemonicFromEntropy(entropy: [UInt8]) throws -> String {
        let mneomonic = try Mnemonic.fromEntropy(entropy: entropy)
        return mneomonic.asString()
    }
    
    func makeDescriptor(mnemonic: String, isChange: Bool) throws -> Descriptor {
        var index = KeychainKind.external
        if isChange { index = KeychainKind.internal }
        let mnemonic = try Mnemonic.fromString(mnemonic: mnemonic)
        let sec = DescriptorSecretKey(network: Network.bitcoin, mnemonic: mnemonic, password: nil)
        let desc = Descriptor.newBip86(secretKey: sec, keychain: index, network: Network.bitcoin)
        return desc
    }
    
    func nextAddress() -> String? {
        let address = try? wallet?.getAddress(addressIndex: AddressIndex.lastUnused)
        if let address = address {
            return address.address.asString()
        }
        return nil
    }

    func listTxs() {
        let txs = try? wallet?.listTransactions(includeRaw: true)
        var temp: [TransactionListItemModel] = []
        
        if let txs = txs {
            for tx in txs {
                let wasSent = tx.sent > tx.received
                var wasConfirmed: Bool = false
                var time: UInt64 = 0
                if let confirmation = tx.confirmationTime {
                    wasConfirmed = true
                    time = confirmation.timestamp
                }
                var sats: UInt64
                if wasSent {
                    sats = tx.sent - tx.received
                } else {
                    sats = tx.received - tx.sent
                }
                let amount = converter.satsToBtc(sats: sats)
                temp.append(TransactionListItemModel(id: tx.txid, amount: amount, wasSent: wasSent, wasConfirmed: wasConfirmed, onChain: true, detail: "", time: time))
            }
        }
        self.txs = temp
    }
    
    func refresh() {
        print("Syncing with Esplora")
        if let chain = self.blockchain {
            let _ = try? wallet?.sync(blockchain: chain, progress: nil)
        }
        self.receiveAddress = self.nextAddress()
        self.listTxs()
        print("Done syncing")
    }
    
    func getBalance() -> UInt64? {
        let balance = try? wallet?.getBalance()
        if let balance = balance {
            return balance.total
        }
        return nil
    }
    
    func getTransactions() -> [TransactionListItemModel] {
        return self.txs
    }
    
    func requestPayment(fiat: Float, exchange: Float) -> BitcoinPaymentRequestModel? {
        let sats = UInt64(converter.fiatToSats(exchangeRate: exchange, fiat: fiat))
        let btc = converter.satsToBtc(sats: sats)
        if let address = self.receiveAddress {
            let uri = "bitcoin:\(address)?amount=\(btc)"
            return BitcoinPaymentRequestModel(uri: uri, address: address)
        }
        return nil
    }
    
    func getBalanceInBitcoin() -> Float? {
        if let balance = self.balance {
            return self.converter.satsToBtc(sats: balance)
        }
        return nil
    }
    
    func sendPayment(address: String, bitcoinAmount: Float, satVb: Float, sendMax: Bool) async -> Bool? {
        let address = try? Address(address: address).scriptPubkey()
        let sats = UInt64(self.converter.btcToSats(btc: bitcoinAmount))
        if address == nil {
            return nil
        }
        if wallet == nil {
            return nil
        }
        if self.blockchain == nil {
            return nil
        }
        if sendMax {
            do {
                let build = try TxBuilder()
                                    .drainWallet()
                                    .drainTo(script: address!)
                                    .feeRate(satPerVbyte: satVb)
                                    .enableRbf()
                                    .finish(wallet: wallet!)
                let _ = try wallet!.sign(psbt: build.psbt, signOptions: nil)
                try self.blockchain!.broadcast(transaction: build.psbt.extractTx())
                self.broadcastPayment = .succeed
                return true
            } catch {
                dump(error)
                self.broadcastPayment = .fail
                return false
            }
        } else {
            do {
                let build = try TxBuilder()
                                    .addRecipient(script: address!, amount: sats)
                                    .feeRate(satPerVbyte: satVb)
                                    .enableRbf()
                                    .finish(wallet: wallet!)
                let _ = try wallet!.sign(psbt: build.psbt, signOptions: nil)
                try self.blockchain!.broadcast(transaction: build.psbt.extractTx())
                self.broadcastPayment = .succeed
                return true
            } catch {
                self.broadcastPayment = .fail
                return false
            }
        }
    }
}
