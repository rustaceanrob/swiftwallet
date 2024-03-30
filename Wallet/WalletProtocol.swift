//
//  Wallet.swift
//  Magma
//
//  Created by Robert Netzke on 2/9/24.
//

import Foundation

protocol WalletProtocol {
    func refresh()
    func getBalance() -> UInt64?
    func getTransactions() -> [TransactionListItemModel]
}
