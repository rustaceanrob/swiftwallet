//
//  WelcomeView.swift
//  Magma
//
//  Created by Robert Netzke on 12/18/23.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        TabView {
            WelcomeMessageView(title: String(localized: "Hello!"), caption: String(localized: "You will need a couple minutes to set up your new wallet."), imgRef: "hand.wave")
            WelcomeMessageView(title: String(localized: "Recovery"), caption: String(localized: "You will need to write down a simple recovery phrase."), imgRef: "exclamationmark.bubble.fill")
            WelcomeMessageView(title: String(localized: "Storage"), caption: String(localized: "Store your phrase in a secure location. Anyone with your phrase can spend your Bitcoin."), imgRef: "magsafe.batterypack.fill")
            WelcomeMessageView(title: String(localized: "Security"), caption: String(localized: "Use a pen and paper to write down the recovery phrase. Do not use screenshots, notes, or password managers."), imgRef: "lock.doc")
            FinalMessageView()
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
