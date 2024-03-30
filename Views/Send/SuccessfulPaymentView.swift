//
//  SuccessfulPaymentView.swift
//  Magma
//
//  Created by Robert Netzke on 1/25/24.
//

import SwiftUI

struct SuccessfulPaymentView: View {
    
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
                    Text("Payment sent!")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text("\(getTime())")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
                Image(systemName: "checkmark.circle")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .scaledToFit()
                    .foregroundColor(.green)
                Spacer()
                Spacer()
            }
        }
    }
}

struct SuccessfulPaymentView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessfulPaymentView()
    }
}
