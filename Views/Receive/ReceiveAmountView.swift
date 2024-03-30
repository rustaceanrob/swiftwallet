//
//  ReceiveAmountView.swift
//  Magma
//
//  Created by Robert Netzke on 12/16/23.
//

import SwiftUI

enum UserButton: String {
    case zero = "0"
    case one = "1"
    case two = "2"
    case three = "3"
    case four = "4"
    case five = "5"
    case six = "6"
    case seven = "7"
    case eight = "8"
    case nine = "9"
    case decimal = "."
    case back = "-"
}

struct ReceiveAmountView: View {
    @EnvironmentObject var manager: GlobalStateManager
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") var symbol = "$"
    
    @State var isLoading = false
    @State var paymentReady = false
    @State var amount: String = "0"
    @State var bitcoinAmount: Float = 0.00000000
    @State var isShowingTransaction = false
    @State var error = false
    @State var success = false
    @State private var lnInvoice: LnInvoiceRequestModel? = nil
    @State private var bitcoinPayment : BitcoinPaymentRequestModel? = nil
    @State var description: String = ""
    @State var exchange: Float?
    
    private var matrix: [[UserButton]] = [[.one, .two, .three],
                                          [.four, .five, .six],
                                          [.seven, .eight, .nine],
                                          [.decimal, .zero, .back]]
    
    init() {
        let converter = Converter()
        symbol = converter.tickerToSymbol(ticker: selectedFiat)
    }
    
    var body: some View {
        NavigationStack {
            FadesView {
                Spacer()
                Spacer()
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
                    //                    Text("\(symbol)\(Float(amount)!, specifier: "%.2f")")
                    //                        .font(.largeTitle)
                    //                        .fontWeight(.semibold)
                    
                    HStack(spacing: 2) {
                        if let exchange = manager.exchangeRate {
                            Text("\(Float(amount)! / exchange, specifier: "%.8f") Bitcoin")
                                .font(.title2)
                                .fontWeight(.light)
                        }
                    }
                }
                Spacer()
                HStack {
                    TextField("What is this for?", text: $description)
                        .multilineTextAlignment(.center)
                }
                Spacer()
                VStack {
                    ForEach(matrix, id: \.self) { row in
                        HStack(spacing: 20) {
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
                                    
                                    bitcoinAmount = (Float(amount) ?? 0.00) / (manager.exchangeRate ?? 1.00)
                                    
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
                Spacer()
                HStack {
                    Text("Request")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .background(RoundedRectangle(cornerRadius: 10)
                            .frame(width: calcSubmitButtonWidth(), height: 50)
                            .foregroundColor(.accentColor))
                        .foregroundColor(.white)
                        .onTapGesture {
                            Task {
                                print("Generating invoice")
                                self.paymentReady = false
                                self.success = false
                                self.error = false
                                self.lnInvoice = nil
                                self.lnInvoice = await manager.fetchInvoice(fiat: Float(amount)!, description: description)
                                if self.lnInvoice == nil {
                                    self.error = true
                                }
                                self.bitcoinPayment = await manager.fetchReceiveBitcoin(fiat: Float(amount)!)
                                print(self.bitcoinPayment?.address ?? "")
                                if self.bitcoinPayment == nil {
                                    self.error = true
                                }
                                print("Invoice set")
                                self.paymentReady = true
                            }
                            isShowingTransaction.toggle()
                        }
                }
                .padding(.bottom, 20)
                Spacer()
            }
            .sheet(isPresented: $isShowingTransaction) {
                if self.paymentReady {
                    if !success {
                        ReceiveQRSliderView(fiat: amount, lnInvoice: self.lnInvoice!, btcReq: self.bitcoinPayment!)
                            .presentationDetents([.height(750)])
                            .presentationDragIndicator(.visible)
                    } else {
                        InvoicePaymentSuccess()
                            .onTapGesture {
                                self.isShowingTransaction = false
                            }
                    }
                } else {
                    if !error && !success {
                        LoadingScreen()
                    } else if error {
                        InvoiceCreateError()
                            .onTapGesture {
                                self.isShowingTransaction = false
                            }
                    }
                }
                
            }
        }
        .blur(radius: isShowingTransaction ? 5: 0)
        .onReceive(manager.lightningWallet.listener.$nextEvent, perform: { e in
            if e.contains("invoicePaid") {
                Task {
                    success = true
                    await manager.refresh()
                }
            }
        })
    }
        
    
    func calcButtonWidth() -> CGFloat {
        return (UIScreen.main.bounds.width - (4 * 12)) / 3.3
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

struct ReceiveAmountView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveAmountView()
            .environmentObject(GlobalStateManager())
    }
}

