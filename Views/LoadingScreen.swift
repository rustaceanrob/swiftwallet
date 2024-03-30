//
//  LoadingScreen.swift
//  Magma
//
//  Created by Robert Netzke on 1/2/24.
//

import SwiftUI
import Combine

struct LoadingScreen: View {
    @State var isAnimating: Bool = false
    @State private var opacity = 0.0
    let timing: Double
    
    let maxCounter = 3
    let frame: CGSize
    
    init(size: CGFloat = 90, speed: Double = 0.5) {
        timing = speed * 2
        frame = CGSize(width: size, height: size)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.primary)
                .frame(height: frame.height / 3)
                .offset(
                    x: 0,
                    y: isAnimating ? -frame.height / 3 : 0
                )
            Circle()
                .fill(.primary)
                .frame(height: frame.height / 3)
                .offset(
                    x: isAnimating ? -frame.height / 3 : 0,
                    y: isAnimating ? frame.height / 3 : 0
                )
            Circle()
                .fill(.primary)
                .frame(height: frame.height / 3)
                .offset(
                    x: isAnimating ? frame.height / 3 : 0,
                    y: isAnimating ? frame.height / 3 : 0
                )
        }
        .frame(width: frame.width, height: frame.height, alignment: .center)
        .animation(Animation.easeOut(duration: timing)
            .repeatForever(autoreverses: true))
        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
        .animation(Animation.easeOut(duration: timing)
            .repeatForever(autoreverses: true))
        .opacity(opacity)
        .animation(.easeInOut, value: opacity)
        .onAppear {
            isAnimating = true
            opacity = 1.0
        }
    }
}

struct LoadingScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoadingScreen()
    }
}
