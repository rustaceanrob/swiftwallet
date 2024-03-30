//
//  SettingsView.swift
//  Magma
//
//  Created by Robert Netzke on 1/6/24.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var reader = NFCHandler()
    
    @EnvironmentObject var manager: GlobalStateManager
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") private var fiatSymbol = "$"
    @AppStorage("card") private var selectedCardStyle = "Waves"
    @AppStorage("denom") private var selectedDenomination = "btc"
    @AppStorage("privacyMode") var privacyMode: Bool = false
    
    @State private var showDeleteAlert = false
    @State var didApproveFaceId: Bool = false
    @State var didApproveNotifications: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text(String(localized: "Preferences"))) {
                Picker(String(localized: "Currency"), selection: $selectedFiat) {
                    Text("United States Dollar")
                        .tag("USD")
                    Text("Euro")
                        .tag("EUR")
                    Text("Japanese Yen")
                        .tag("JPY")
                }
                .onChange(of: selectedFiat) { newSelectedFiat in
                    print(newSelectedFiat)
                    let newSym = tickerToSymbol(ticker: newSelectedFiat)
                    print(newSym)
                    self.fiatSymbol = newSym
                }
                Picker(String(localized: "Card Style"), selection: $selectedCardStyle) {
                    Text("Default")
                        .tag("Waves")
                    Text("Digital Gold")
                        .tag("gold")
                    Text("Ocean Blue")
                        .tag("BlueGradient")
                    Text("Magma")
                        .tag("magma")
                    Text("La Playa")
                        .tag("salvador")
                    Text("Agentina")
                        .tag("agentina")
                }
//                Picker("Preferred Unit", selection: $selectedDenomination) {
//                    Text("Bitcoin")
//                        .tag("btc")
//                    Text("Satoshi")
//                        .tag("sat")
//                }
                Toggle(String(localized: "Privacy Mode"), isOn: $privacyMode)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                Toggle(String(localized: "Face ID"), isOn: $didApproveFaceId)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
//                Toggle("Notifications", isOn: $didApproveNotifications)
//                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                
            }
//            Section(header: Text(String(localized: "Card Management"))) {
//                Button {
//                    Task {
//                        let info = manager.lightningWallet.getNodeInfo()
//                        if let info = info {
//                            print("Node info present")
//                            let message = info.nodeId
//                            reader.write(message: message)
//                        } else {
//                            print("No info available")
//                        }
//                    }
//                } label: {
//                    Text(String(localized: "Add Inflo Card"))
//                        .foregroundColor(.primary)
//                }            }
            Section(header: Text(String(localized: "Advanced"))) {
                NavigationLink {
                    NodeDetailView()
                } label: {
                    Text(String(localized: "Node Information"))
                }
//                Button {
//
//                } label: {
//                    Text("Cloud Backup")
//                        .foregroundColor(.primary)
//                }
            }
            Section(header: Text(String(localized: "Information"))) {
                NavigationLink {
                    About()
                } label: {
                    Text(String(localized: "About"))
                }
                NavigationLink {
                    TermsAndConditionsView()
                } label: {
                    Text(String(localized: "Terms and Conditions"))
                }
            }
            Section(header: Text(String(localized: "Danger Zone"))) {
                Button {
                    
                } label: {
                    Text(String(localized: "Show Recovery Phrase"))
                        .foregroundStyle(.red)
                }
                Button {
                    showDeleteAlert = true
                } label: {
                    Text(String(localized: "Delete Wallet"))
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle(String(localized: "Settings"))
        .onAppear {
            didApproveFaceId = !manager.faceIdNotApproved()
        }
        .onDisappear {
            if didApproveFaceId == false {
                manager.userDisapprovedFaceID()
            }
            
            if didApproveFaceId && manager.faceIdNotApproved() {
                manager.userApprovedFaceID()
            }
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text(String(localized: "Delete your wallet?")),
                message: Text(String(localized: "Deleting a wallet cannot be undone.")),
                primaryButton: .default(Text(String(localized: "Cancel"))),
                secondaryButton: .destructive(Text(String(localized: "Confirm"))) {
                    manager.nuke()
                }
            )
        }
    }
    
    func tickerToSymbol(ticker: String) -> String {
        if ticker == "USD" {
            return "$"
        } else if ticker == "EUR" {
            return "€"
        } else if ticker == "JPY" {
            return "¥"
        } else {
            return "$"
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(GlobalStateManager())
    }
}
