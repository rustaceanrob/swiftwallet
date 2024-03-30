//
//  AppRouter.swift
//  Magma
//
//  Created by Robert Netzke on 1/2/24.
//

import SwiftUI

struct AppRouter: View {
    
    @EnvironmentObject var manager: GlobalStateManager
    
    var body: some View {
        switch manager.walletType {
        case .hasNone: WelcomeView()
        case .needsBackup: QuizStackView()
        case .card: MainTabView()
        case .software: MainTabView()
        default: ProgressView()
        }
    }
}

struct MainTabView: View {
    
    @EnvironmentObject var manager: GlobalStateManager
    
    var body: some View {
        TabView() {
            ReceiveAmountView()
                .tabItem {
                    Image(systemName: "arrow.down.right.circle")
                    Text(String(localized: "Request"))
                }
            HomeView()
                .tabItem {
                    Image(systemName: "creditcard.fill")
                    Text(String(localized: "Wallet"))
                }
            SendToQRView()
                .tabItem {
                    Image(systemName: "arrow.up.right.circle")
                    Text(String(localized: "Pay"))
                }
        }
        .onAppear {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithDefaultBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            // correct the transparency bug for Navigation bars
//            let navigationBarAppearance = UINavigationBarAppearance()
//            navigationBarAppearance.configureWithOpaqueBackground()
//            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
                 
            Task {
                await manager.refreshAll()
            }
        }
    }
}

struct AppRouter_Previews: PreviewProvider {
    static var previews: some View {
        AppRouter()
            .environmentObject(GlobalStateManager())
    }
}
