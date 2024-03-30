//
//  BitcoinPaymentsUnderConstructionView.swift
//  Magma
//
//  Created by Robert Netzke on 1/25/24.
//

import SwiftUI




struct BitcoinPaymentUnderConstructionView: View {
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") private var symbol = "$"
    
    @State var didCopy = false
    
    let message: String
    let caption: String
    let amount: String
    
    private let pasteboard = UIPasteboard.general
    
    init(message: String, caption: String, amount: String) {
        self.message = message
        self.caption = caption
        self.amount = amount
    }
    
    func calcWidth() -> CGFloat {
        return UIScreen.main.bounds.width * 0.80
    }
    
    func truncateInvoice(input: String) -> String {
        return "\(input.prefix(10))...\(input.suffix(5))"
    }
    
    var body: some View {
        VStack() {
            Spacer()
            VStack(spacing: 5) {
                Text("\(caption) for \(symbol)\(Float(amount)!, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("Not available yet! Sorry TestFlight users (:")
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "hammer.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 300)
                .padding()
                
            Spacer()
            VStack(alignment: .leading) {
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 5) {
                        Image(systemName: "lightbulb")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 15)
                        Text("Tip")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    Text(message)
                        .font(.callout)
                        .foregroundColor(Color(.systemGray))
                }
            }
            .frame(width: calcWidth())
            Spacer()
        }
    }
}

struct BitcoinPaymentUnderConstructionView_Preview: PreviewProvider {
    static var previews: some View {
        BitcoinPaymentUnderConstructionView(message: "", caption: "", amount: "10")
    }
}

