//
//  WalletTransactionListItemModel.swift
//  Magma
//
//  Created by Robert Netzke on 12/16/23.
//

import Foundation

struct TransactionListItemModel: Hashable {
    var id: String
    var amount: Float
    var wasSent: Bool
    var wasConfirmed: Bool
    var onChain: Bool
    var detail: String
    var fiatAmount: Float?
    var time: UInt64
}
