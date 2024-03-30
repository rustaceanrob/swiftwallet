//
//  SendToNodeView.swift
//  Magma
//
//  Created by Robert Netzke on 2/2/24.
//

import SwiftUI

struct SendToLnUrlView: View {
    
    enum FocusedField {
        case numberPad
        case descriptionPad
    }
    
    @EnvironmentObject var manager: GlobalStateManager
    
    private var exchange: Float?
    private var lnUrl: String?
    
    @State var sendingPayment: Bool = false
    @State var amount: String = "0"
    @State var bitcoinAmount: Float = 0.00000000
    @State private var description: String = ""
    @State private var minimumFiat: Float?
    @FocusState private var focusField: FocusedField?
    @AppStorage("symbol") var symbol = "$"
    
    private var matrix: [[UserButton]] = [[.one, .two, .three],
                                          [.four, .five, .six],
                                          [.seven, .eight, .nine],
                                          [.decimal, .zero, .back]]
    
    
    init(exchange: Float? = nil, lnUrl: String?) {
        self.exchange = exchange
        self.lnUrl = lnUrl
    }

    var body: some View {
        
        VStack {
            FadesView {
                Spacer()
                Spacer()
                if let url = self.lnUrl {
                    HStack {
                        Text("\(url)")
                            .font(.callout)
                            .foregroundStyle(.gray)
                    }
                }
                VStack(alignment: .center, spacing: 5) {
                    if amount.contains(".") {
                        Text("\(symbol)\(Float(amount)!, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    } else {
                        Text("\(symbol)\(amount)")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                    }
                    HStack(spacing: 2) {
                        if let exchange = self.exchange {
                            Text("\(Float(amount)! / exchange, specifier: "%.8f") Bitcoin")
                                .font(.title2)
                                .fontWeight(.light)
                        }
                    }
                }
                if let fiatMin = self.minimumFiat {
                    Spacer()
                    HStack {
                        Text("Minimum \(symbol)\(fiatMin, specifier: "%.2f")")
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                }
//                HStack {
//                    TextField("Add comment", text: $description)
//                        .multilineTextAlignment(.center)
//                }
                Spacer()
                VStack {
                    ForEach(matrix, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(row, id: \.self) { item in
                                Button {
                                    // there is an existing decimal already
                                    if let dotIndex = amount.firstIndex(of: ".") {
                                        let charactersAfterDot = amount.suffix(from: amount.index(after: dotIndex))
                                        if charactersAfterDot.count >= 2 {
                                            if item.rawValue != "-" { return }
                                        }
                                    }
                                    // create a decimal
                                    if item.rawValue == "." {
                                        if amount.contains(".") {
                                            return
                                        }
                                        if amount == "0" {
                                            amount = "0." //??
                                            return
                                        }
                                    }
                                    // if the amount is not zero remove the last character
                                    if amount == "0" && item.rawValue != "-" {
                                        amount = "\(item.rawValue)"
                                    } else if item.rawValue == "-" {
                                        amount = getBackspace(current: amount, n: amount.count)
                                    } else {
                                        amount = amount + "\(item.rawValue)"
                                    }
                                    
                                    bitcoinAmount = (Float(amount) ?? 0.00) / (self.exchange ?? 1.00)
                                    
                                } label: {
                                    if (item.rawValue != "-") {
                                        Text("\(item.rawValue)")
                                            .frame(width: calcButtonWidth(), height: calcButtonWidth())
                                            .font(.title)
                                            .foregroundColor(Color.primary)
                                            .fontWeight(.light)
                                    } else {
                                        Image(systemName: "delete.left")
                                            .frame(width: calcButtonWidth(), height: calcButtonWidth())
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
                HStack {
                    if sendingPayment {
                        FadesView {
                            ProgressView()
                        }
                        .frame(width: 200, height: 50)
                    } else {
                        Text("Pay")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .background(RoundedRectangle(cornerRadius: 10)
                                .frame(width: 200, height: 50)
                                .foregroundColor(sendingPayment ? .gray : .accentColor))
                            .foregroundColor(.white)
                            .onTapGesture {
                                Task {
                                    sendingPayment = true
                                    print("Sending payment")
                                    await manager.lightningWallet.sendLightningInvoicePayment(fiatAmount: Float(amount)!, paymentType: .lnUrl, userDescription: self.description)
                                    print("Status updated")
                                }
                            }
                    }
                }
                .padding(.bottom, 20)
                .padding(.top, 20)
            }
            .onAppear {
                self.minimumFiat = manager.lightningWallet.getLnUrlMin()
            }
        }
    }
    
    func calcButtonWidth() -> CGFloat {
        return (UIScreen.main.bounds.width - (4 * 12)) / 3.2
    }
    
    func calcSubmitButtonWidth() -> CGFloat {
        return (UIScreen.main.bounds.width * 0.8)
    }
    
    func getBackspace(current: String, n: Int) -> String {
        if n >= 2 {
            let firstNMinus1Characters = current.prefix(n - 1)
            return String(firstNMinus1Characters)
        } else {
            return "0"
        }
    }
}

struct SendToLnUrlView_Previews: PreviewProvider {
    static var previews: some View {
        SendToLnUrlView(exchange: 40_000.0, lnUrl: "rustaceanrob@stacker.news")
            .environmentObject(GlobalStateManager())
    }
}
