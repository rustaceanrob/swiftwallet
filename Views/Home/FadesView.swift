//
//  FadesView.swift
//  Magma
//
//  Created by Robert Netzke on 1/26/24.
//

import SwiftUI

import SwiftUI

struct FadesView<Content: View>: View {

    var content: Content
    @State private var opacity = 0.0

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        .opacity(opacity)
        .animation(.easeInOut, value: opacity)
        .onAppear {
            opacity = 1.0
        }
    }
}

struct FadesView_Previews: PreviewProvider {
    static var previews: some View {
        FadesView {
            Text("Hello world!")
        }
    }
}
