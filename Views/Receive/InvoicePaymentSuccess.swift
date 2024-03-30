//
//  InvoicePaymentSuccess.swift
//  Magma
//
//  Created by Robert Netzke on 1/20/24.
//

import SwiftUI

struct InvoicePaymentSuccess: View {
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .long
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    var body: some View {
        FadesView {
            VStack(spacing: 50) {
                HStack() {
                    Image(systemName: "xmark")
                    Spacer()
                }
                .padding(30)
                Spacer()
                VStack(spacing: 5) {
                    Text("You got paid!")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("\(getTime())")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
                Image(systemName: "party.popper")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100)
                    .foregroundColor(.accentColor)
                Spacer()
                Spacer()
            }
        }
    }
}

struct InvoicePaymentSuccess_Previews: PreviewProvider {
    static var previews: some View {
        InvoicePaymentSuccess()
    }
}
