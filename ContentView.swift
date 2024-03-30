//
//  ContentView.swift
//  Magma
//
//  Created by Robert Netzke on 12/16/23.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    
    @EnvironmentObject var manager: GlobalStateManager
    @State private var isUnlocked = false
    
    var body: some View {
        Group {
            if isUnlocked {
                AppRouter()
            } else {
                FadesView {
                    Image("AppIconTransparent")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                }
            }
        }
        .onAppear{
            if manager.faceIdNotApproved() {
                print("key doesn't exist")
                isUnlocked = true
                return
            }
            authenticateWithBiometrics()
        }
    }
    
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = String(localized: "Unlock to continue.")
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [self] success, authenticationError in
                if success {
                    isUnlocked = true
                } else {
                    authenticateWithBiometrics()
                }
            }
        } else {
            isUnlocked = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GlobalStateManager())
    }
}
