//
//  WelcomeMessageView.swift
//  Magma
//
//  Created by Robert Netzke on 12/18/23.
//

import SwiftUI

struct WelcomeMessageView: View {
    var title: String
    var caption: String
    var imgRef: String
    
    init(title: String, caption: String, imgRef: String) {
        self.title = title
        self.caption = caption
        self.imgRef = imgRef
    }
    
    
    var body: some View {
        VStack(spacing: 50) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Image(systemName: imgRef)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .foregroundColor(.accentColor)
            Text(caption)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)
        }
    }
}

struct WelcomeMessageView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeMessageView(title: "Welcome", caption: "You will need a couple minutes to set up your wallet", imgRef: "clock")
    }
}
