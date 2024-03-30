//
//  SendViewIcon.swift
//  Magma
//
//  Created by Robert Netzke on 2/1/24.
//

import SwiftUI

struct SendViewIcon: View {
    
    var img: String
    
    init(img: String) {
        self.img = img
    }
    
    var body: some View {
        Image(systemName: self.img)
            .resizable()
            .scaledToFit()
            .frame(width: 25, height: 25)
            .padding(10)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.primary, lineWidth: 1)
//                    .foregroundColor(.accentColor)
//
//            )
            
    }
}

struct SendViewIcon_Previews: PreviewProvider {
    static var previews: some View {
        SendViewIcon(img: "globe")
    }
}
