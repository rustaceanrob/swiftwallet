//
//  InvoiceCreateError.swift
//  Magma
//
//  Created by Robert Netzke on 1/20/24.
//

import SwiftUI

struct InvoiceCreateError: View {
    
    var body: some View {
        FadesView {
            VStack(spacing: 50) {
                HStack() {
                    Image(systemName: "xmark")
                    Spacer()
                }
                .padding(30)
                Spacer()
                Text("Something went wrong.")
                    .font(.title)
                    .fontWeight(.semibold)
                Image(systemName: "exclamationmark.bubble")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundColor(.gray)
                Text("The amount you set may be too small or you are not connected to the internet.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                Spacer()
            }
        }
    }
}

struct InvoiceCreateError_Previews: PreviewProvider {
    static var previews: some View {
        InvoiceCreateError()
    }
}
