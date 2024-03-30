//
//  About.swift
//  Magma
//
//  Created by Robert Netzke on 1/24/24.
//

import SwiftUI

struct About: View {
    var body: some View {
        VStack {
            Text("Magma is a Bitcoin and Lightning Network wallet focused on ease-of-use, simplicity, and effectiveness. The experience of using Bitcoin should be as easy for beginners as it is for advanced users, and that philosophy has driven the development of Magma. Above all, users have control over their Bitcoin, allowing even the most novice user to use Bitcoin in a self-sovereign way. ")
                .font(.body)
            Spacer()
        }
        .padding()
        .navigationTitle("About")
    }
}

struct About_Previews: PreviewProvider {
    static var previews: some View {
        About()
    }
}
