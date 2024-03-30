//
//  SuccessfulQRParseView.swift
//  Magma
//
//  Created by Robert Netzke on 1/21/24.
//

import SwiftUI

struct SuccessfulQRParseView: View {
    @EnvironmentObject var manager: GlobalStateManager
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") var symbol = "$"
    
    private let data: String
    
    init(data: String) {
        self.data = data
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//            .onAppear {
//                let parsed = manager.lightningWallet.parseUserInput(userInput: self.data)
//                if parsed != nil {
//
//                }
//            }
    }
}

struct SuccessfulQRParseView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessfulQRParseView(data: "lnbc23960n1pj6mys8sp506a8ysmjndlywayesssym8jfc08vzcaefxc84sh0rxj5ls5epxcspp5zwecdatz9g5vgs8wvze3cc3vltpf956weqnqc74dpy5qs67x6kaqdqsfphk6efqg3jhqmm5cqzysrzjqtypret4hcklglvtfrdt85l3exc0dctdp4qttmtcy5es3lpt6uts6ef4t5ezgsxwrvqqqqqqqqqqqqqqygrzjqtypret4hcklglvtfrdt85l3exc0dctdp4qttmtcy5es3lpt6uts6ef4t5ezgsxwrvqqqqqqqqqqqqqqygrzjqtypret4hcklglvtfrdt85l3exc0dctdp4qttmtcy5es3lpt6uts6dvurj66qcqv9yqqqqqqqqqqqqqqyg9qxpqysgqwwrpspmjfrznexy42hhdk293zkxh85muruzk3hfr8vxct6zdn29y9ndmgfeydvjwh4luryj7hwmwlr5654stknmwr3r4anlr3vsqygqqvdfpst")
    }
}
