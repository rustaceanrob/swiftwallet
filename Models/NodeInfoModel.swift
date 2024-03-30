//
//  NodeInfoModel.swift
//  Magma
//
//  Created by Robert Netzke on 1/25/24.
//

import Foundation

struct NodeInfoModel {
    var height: UInt32
    var inboundLiq: UInt64
    var nodeId: String
    var maxAmountPayable: UInt64
    var maxAmountReceivable: UInt64
    var peers: [String]
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
