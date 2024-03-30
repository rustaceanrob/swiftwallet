//
//  NodeDetailView.swift
//  Magma
//
//  Created by Robert Netzke on 1/25/24.
//

import SwiftUI

struct NodeDetailView: View {
    
    @EnvironmentObject var manager: GlobalStateManager
    @State private var information: NodeInfoModel?
    
    var body: some View {
        List {
            if let information = self.information {
                VStack(alignment: .leading) {
                    Text("Node ID")
                    Text("\(information.nodeId)")
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text("Inbound Liquidity")
                    Text("\(information.inboundLiq) (mSatoshi)")
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text("Maximum Lightning Invoice Payable")
                    Text("\(information.maxAmountPayable) (mSatoshi)")
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text("Maximum Lightning Invoice Receivable")
                    Text("\(information.maxAmountReceivable) (mSatoshi)")
                        .foregroundColor(.gray)
                }
                VStack(alignment: .leading) {
                    Text("Chain Height")
                    Text("\(information.height)")
                        .foregroundColor(.gray)
                }
            } else {
                LoadingScreen()
            }
        }
        .navigationTitle("Node Information")
        .onAppear {
            information = manager.getNodeInfo()
        }
    }
}

struct NodeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NodeDetailView()
            .environmentObject(GlobalStateManager())
    }
}
