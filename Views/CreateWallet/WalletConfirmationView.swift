//
//  WalletConfirmationView.swift
//  Magma
//
//  Created by Robert Netzke on 1/6/24.
//

import SwiftUI

struct WalletConfirmationView: View {
    
    @EnvironmentObject var manager: GlobalStateManager
    @State var didApproveFaceId: Bool = false
    @State var didApproveNotifications: Bool = false
    @State var confirmedWallet: Bool = false
    @State var didUserConfirmRecoveryPhrase: Bool = false
    @State var didUserConfirmResponsibility: Bool = false
    
    var body: some View {
        VStack() {
            Spacer()
            Text(String(localized: "Your wallet is ready!"))
                .font(.title)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "checkmark.circle")
                .resizable()
                .frame(width: 150, height: 150)
                .scaledToFit()
                .foregroundColor(.green)
            Spacer()
            VStack(alignment: .leading, spacing: 20) {
                Divider()
                HStack() {
                    VStack(alignment: .leading) {
                        Text(String(localized: "Use FaceID"))
                            .font(.headline)
                        Text(String(localized: "Increase the security of your wallet."))
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    Toggle("", isOn: $didApproveFaceId)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
                Divider()
                HStack() {
                    VStack(alignment: .leading) {
                        Text(String(localized: "Recovery Phrase"))
                            .font(.headline)
                        Text(String(localized: "I wrote down and stored my backup."))
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    Toggle("", isOn: $didUserConfirmRecoveryPhrase)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
                Divider()
                HStack() {
                    VStack(alignment: .leading) {
                        Text(String(localized: "Responsibility"))
                            .font(.headline)
                        Text(String(localized: "I understand only I can recover my wallet."))
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    Toggle("", isOn: $didUserConfirmResponsibility)
                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
                Divider()
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text("Turn On Notifications")
//                            .font(.headline)
//                        Text("Receive notifications when you get paid.")
//                            .font(.callout)
//                            .foregroundColor(.secondary)
//                    }
//                    Toggle("", isOn: $didApproveNotifications)
//                        .toggleStyle(SwitchToggleStyle(tint: .accentColor))
//                }
//                Divider()
            }
            .padding(.horizontal, 20)
            Spacer()
            Button(action: {
                Task {
                    if didApproveFaceId {
                        manager.userApprovedFaceID()
                    }
                    self.confirmedWallet = true
                    await manager.userMadeWallet()
                }
            }, label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
                    .font(.title3)
            })
            .foregroundColor(didUserConfirmResponsibility && didUserConfirmRecoveryPhrase ? .accentColor: .gray)
            .disabled(!didUserConfirmResponsibility || !didUserConfirmRecoveryPhrase)
            .padding()
//            Button(action: {
//
//            }, label: {
//                Text("Use Magma Card")
//                    .frame(maxWidth: .infinity)
//                    .font(.title3)
//            })
            Spacer()
        }
        .sheet(isPresented: $confirmedWallet, content:  {
            LoadingScreen()
        })
    }
}

struct WalletConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        WalletConfirmationView()
            .environmentObject(GlobalStateManager())
    }
}
