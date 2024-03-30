//
//  GlobalStateManager.swift
//  Magma
//
//  Created by Robert Netzke on 1/2/24.
//

import Foundation
import LocalAuthentication

enum WalletType {
    case hasNone
    case needsBackup
    case software
    case card
}

enum ManagerErrors: Error {
    case InvalidRecovery
}

final class GlobalStateManager: ObservableObject {
    private let MNEMONIC_KEY = "mnemonic"
    private let ENCRYPTED_MNEMONIC_KEY = "combined"
    private let USER_BACKEDUP_KEY = "userBackedupWallet"
    private let USER_APPROVED_FACE_ID = "faceIdEnabled"
    
    private let converter = Converter()
    private let keychain = KeychainHandler()
    private let rand = TRNGHandler()
    private let crypto = CryptographyHandler()
    private var nodeFailure: Bool = false
    let bitcoinWallet = BitcoinWallet()
    let lightningWallet = LightningWallet()
    
    @Published var walletType: WalletType?
    @Published var exchangeRate: Float?
    
    // init
    
    init() {
        Task {
            let walletType = await initializeWalletType()
            if walletType == .software {
                await startNode()
                await startBitcoinWallet()
                await getRate()
                await refresh()
            }
            DispatchQueue.main.async {
                self.walletType = walletType
            }
        }
    }
    
    // client updates
    	
    @MainActor
    func getNewWallet() async {
        Task {
            do {
                let bytes = try rand.getRandomBytes(numBytes: 16)
                let mnemonic = try bitcoinWallet.mnemonicFromEntropy(entropy: bytes)
                keychain.set(key: MNEMONIC_KEY, value: mnemonic)
                self.walletType = await initializeWalletType()
            } catch {
                keychain.removeKey(key: MNEMONIC_KEY)
            }
        }
    }
    
    @MainActor
    func userMadeWallet() async {
        Task {
            keychain.set(key: USER_BACKEDUP_KEY, value: "yes")
            await startNode()
            await getRate()
            await refresh()
            self.walletType = await initializeWalletType()
        }
    }
    
    @MainActor
    func userRecoveredWallet(mnenomic: String) async -> Bool {
        keychain.set(key: MNEMONIC_KEY, value: mnenomic)
        keychain.set(key: USER_BACKEDUP_KEY, value: "yes")
        await startNode()
        if nodeFailure {
            print("Node couldn't connect")
            let _ = nuke()
            return false
        }
        Task {
            await getRate()
            await refresh()
            self.walletType = await initializeWalletType()
        }
        return true
    }
    
    @MainActor
    func getRate() async {
        let preferedFiat = UserDefaults.standard.string(forKey: "fiat") ?? "USD"
        let exchange = try? self.lightningWallet.getExchangeRate(fiat: preferedFiat)
        print(exchange ?? "No exchange rate")
        self.exchangeRate = exchange
    }
    
    func requestSeed() -> [String] {
        let mnemonic = try? keychain.get(key: MNEMONIC_KEY)
        if let mnemonic = mnemonic {
            let mnemonicArr = mnemonic.components(separatedBy: " ")
            return mnemonicArr
        }
        return []
    }
    
    func refresh() async {
        self.lightningWallet.refresh()
    }
    
    func refreshAll() async {
        self.lightningWallet.refresh()
        self.bitcoinWallet.refresh()
    }
    
    func getPreferredSymbol() -> String {
        let preferedFiat = UserDefaults.standard.string(forKey: "fiat") ?? "USD"
        return self.converter.tickerToSymbol(ticker: preferedFiat)
    }
    
    func fetchCards(forBitcoin: Bool) -> [CardModel] {
        var cards: [CardModel] = []
        var lnFiatBalance: Float?
        var btcFiatBalance: Float?
        var lnBalance: Float?
        var btcBalance: Float?

        if self.lightningWallet.balance != nil && self.exchangeRate != nil {
            let rounded = UInt64(self.lightningWallet.balance!)
            if forBitcoin {
                lnBalance = converter.satsToBtc(sats: rounded)
            } else {
                lnBalance = Float(rounded)
            }
            lnFiatBalance = converter.satsToFiat(sats: rounded, exchangeRate: self.exchangeRate!)
        }
        
        if self.bitcoinWallet.balance != nil && self.exchangeRate != nil {
            let sats = self.bitcoinWallet.balance!
            if forBitcoin {
                btcBalance = converter.satsToBtc(sats: sats)
            } else {
                btcBalance = Float(sats)
            }
            btcFiatBalance = converter.satsToFiat(sats: sats, exchangeRate: self.exchangeRate!)
        }
        
        var totalBalance: Float?
        var totalFiatBalance: Float?
        if btcBalance != nil && lnBalance != nil {
            totalBalance = btcBalance! + lnBalance!
            totalFiatBalance = btcFiatBalance! + lnFiatBalance!
        }
        cards.append(CardModel(label: "Total Balance", balance: totalBalance, fiatBalance: totalFiatBalance))
        cards.append(CardModel(label: "Spending", balance: lnBalance, fiatBalance: lnFiatBalance))
        cards.append(CardModel(label: "Savings", balance: btcBalance, fiatBalance: btcFiatBalance))
        return cards
    }
    
    func fetchTxHistory() -> [TransactionListItemModel] {
        let bitcoinTxs = self.bitcoinWallet.txs
        let lnTxs = self.lightningWallet.txs
        let allTransactions = bitcoinTxs + lnTxs
        
        let sortedTransactions = allTransactions.sorted { (transaction1, transaction2) -> Bool in
            if transaction1.wasConfirmed && !transaction2.wasConfirmed {
                return false
            } else if !transaction1.wasConfirmed && transaction2.wasConfirmed {
                return true
            } else {
                return transaction1.time > transaction2.time
            }
        }
        
        var temp: [TransactionListItemModel] = []
        for transaction in sortedTransactions {
            if transaction.fiatAmount == nil {
                if let exchange = self.exchangeRate {
                    let someFiat = transaction.amount * exchange
                    var tempTransaction = transaction
                    tempTransaction.fiatAmount = someFiat
                    temp.append(tempTransaction)
                }
            } else {
                temp.append(transaction)
            }
        }
        return temp
    }
    
    func fetchInvoice(fiat: Float, description: String) async -> LnInvoiceRequestModel? {
        if let rate = self.exchangeRate {
            print(rate)
            let inv = self.lightningWallet.lnInvoiceFromFiat(fiat: fiat, exchange: rate, description: description)
            print(inv?.bolt11)
            return inv
        }
        return nil
    }
    
    func fetchPendingSendPayment() -> (String?, String?, Float?, Float?) {
        self.lightningWallet.fetchPendingPayment()
    }
    
    func fetchReceiveBitcoin(fiat: Float) async -> BitcoinPaymentRequestModel? {
        if let rate = self.exchangeRate {
            let addr = self.bitcoinWallet.requestPayment(fiat: fiat, exchange: rate)
            return addr
        }
        return nil
    }
    
    func getOnchainFees() -> FeeDigest? {
        self.lightningWallet.estimatedFees
    }
    
    // danger zone
    func nuke() {
        let keys = [MNEMONIC_KEY, USER_BACKEDUP_KEY, ENCRYPTED_MNEMONIC_KEY, USER_APPROVED_FACE_ID]
        keychain.removeAllKeys(keys: keys)
    }
    
    // biometrics
    func faceIdNotApproved() -> Bool {
        if !keychain.doesKeyExist(key: USER_APPROVED_FACE_ID) { return true }
        return false
    }
    
    func userDisapprovedFaceID() {
        keychain.removeKey(key: USER_APPROVED_FACE_ID)
    }
    
    func userApprovedFaceID() {
        keychain.set(key: USER_APPROVED_FACE_ID, value: "yes")
        authenticateWithBiometrics()
    }
    
    func authenticateWithBiometrics() {
        if !keychain.doesKeyExist(key: USER_APPROVED_FACE_ID) {
            print("key not present")
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            print("key not present")
            let reason = "Unlock to continue."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {_,_ in }
        } else {
            print("biometrics not enabled")
        }
    }
    
    // node info
    func getNodeInfo() -> NodeInfoModel? {
        return self.lightningWallet.getNodeInfo()
    }
    
    // private functions
    private func startNode() async {
        do {
            let phrase = try keychain.get(key: "mnemonic")
            try lightningWallet.startServices(mnemonic: phrase)
        } catch {
            self.nodeFailure = true
        }
    }
    
    private func startBitcoinWallet() async {
        do {
            let phrase = try keychain.get(key: "mnemonic")
            try bitcoinWallet.intializeWorker(mnemonic: phrase)
        } catch {
            self.nodeFailure = true
        }
    }
    
    private func initializeWalletType() async -> WalletType? {
        var hasWallet = false
        var backedUp = false
        var hasMnemonic = false
        var hasBytes = false
        backedUp = keychain.doesKeyExist(key: USER_BACKEDUP_KEY)
        
        if keychain.doesKeyExist(key: MNEMONIC_KEY) {
            hasWallet = true
            hasMnemonic = true
        }
        
        if keychain.doesKeyExist(key: ENCRYPTED_MNEMONIC_KEY) {
            hasWallet = true
            hasBytes = true
        }
        
        if !hasWallet {
            return .hasNone
        } else if hasWallet && !backedUp {
            return .needsBackup
        } else if hasWallet && hasMnemonic {
            return .software
        } else if hasWallet && hasBytes {
            return .card
        } else {
            return nil
        }
    }
}
