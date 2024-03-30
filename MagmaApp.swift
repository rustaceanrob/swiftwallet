//
//  MagmaApp.swift
//  Magma
//
//  Created by Robert Netzke on 12/16/23.
//

import SwiftUI

@main
struct MagmaApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GlobalStateManager())
        }
    }
}
