//
//  FailedPaymentView.swift
//  Magma
//
//  Created by Robert Netzke on 1/25/24.
//

import SwiftUI

struct FailedPaymentView: View {
    
    @EnvironmentObject var manager: GlobalStateManager
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    var body: some View {
        FadesView {
            VStack(spacing: 50) {
                HStack() {
                    Image(systemName: "xmark")
                    Spacer()
                }
                .padding(30)
                Spacer()
                VStack(spacing: 10) {
                    Text("That payment could not be completed at this time.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                    Text("\(getTime())")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
                Button {
                    Task {
                        await manager.lightningWallet.reportRouteFailure()
                    }
                } label: {
                    Text("Send a report")
                }
                Spacer()
                Spacer()
            }
        }
    }
}

struct FailedPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        FailedPaymentView()
            .environmentObject(GlobalStateManager())
    }
}
