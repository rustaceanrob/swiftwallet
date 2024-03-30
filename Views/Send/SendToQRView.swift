//
//  SendToQRView.swift
//  Magma
//
//  Created by Robert Netzke on 12/16/23.
//

import SwiftUI
import CodeScanner

enum SendProgressType {
    case bitcoin
    case lnInvoice
    case lnUrl
    case keysend
    case none
    case successful
    case failed
}

struct SendToQRView: View {
    @EnvironmentObject var manager: GlobalStateManager
    @ObservedObject var reader = NFCHandler()
    
    @AppStorage("card") private var selectedCardStyle = "magma"
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") private var symbol = "$"
    @AppStorage("privacyMode") var privacyMode: Bool = false
    
    @State var cards: [CardModel] = []
    @State var invoiceOrAddress: String?
    @State var description: String?
    @State var fiatAmount: Float?
    @State var bitcoinAmount: Float?
    @State var data: String = ""
    @State var isPresentingScanner: Bool = true
    @State var isPresentingPayment: Bool = false
    @State var paymentType: SendProgressType = .none
    @State var parsed: String = ""
    
    func parseUpdateUI(input: String) {
        Task {
            self.paymentType = await manager.lightningWallet.parseUserInput(userInput: input)
            if self.paymentType == .lnUrl {
                self.invoiceOrAddress = ""
            }
            let (invoice, description, fiat, bitcoin) = manager.fetchPendingSendPayment()
            self.invoiceOrAddress = invoice
            self.fiatAmount = fiat
            self.bitcoinAmount = bitcoin
            self.description = description
            isPresentingScanner = false
            isPresentingPayment = true
        }
    }
    
    var body: some View {
        NavigationStack() {
            FadesView {
                TabView {
                    ForEach(cards, id: \.self) { card in
                        VStack {
                            HStack {
                                HStack(spacing: 2) {
                                    Image(systemName: "bitcoinsign.circle")
                                    Text("\(card.label)")
                                        .font(.title3)
                                    .fontWeight(.semibold)
                                }
                                Spacer()
                                if let balance = card.fiatBalance {
                                    if !privacyMode {
                                        Text("\(symbol)\(balance, specifier: "%.2f")")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                    }
                                } else {
                                    Text("")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                }
                            }
                            .padding()
                            VStack(alignment: .center) {
                                    if let balance = card.balance {
                                        if privacyMode {
                                            Text("********")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                                .blur(radius: 2)
                                        } else {
                                            Text("\(balance, specifier: "%.8f")")
                                                .font(.title3)
                                                .fontWeight(.semibold)
                                        }
                                        if !privacyMode {
                                            Text("Bitcoin")
                                                .font(.subheadline)
                                        }
                                    } else {
                                        Text("")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .blur(radius: 2)
                                    }
                            }
                            .padding()
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .background(
                            Image(selectedCardStyle)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 400)
                                .opacity(0.9)
                        )
                        .cornerRadius(10)
                        .padding()
                    }
                }
                .shadow(color: Color(.systemGray), radius:  2)
                .frame(height: 220)
                .navigationTitle("Payments")
                .tabViewStyle(.page)
                .onTapGesture {
                    privacyMode.toggle()
                }
                List {
                    Button {
                        isPresentingPayment = false
                        isPresentingScanner = true
                    } label: {
                        HStack {
                            SendViewIcon(img: "qrcode.viewfinder")
                            Text("Scan QR")
                        }
                    }
                    Button {
                        reader.scan()
                    } label: {
                        HStack {
                            SendViewIcon(img: "lanyardcard")
                            Text("Tap")
                                .foregroundStyle(.primary)
                        }
                    }
                    Button {
                        if let input = UIPasteboard.general.string {
                            parseUpdateUI(input: input)
                        }
                    } label: {
                        HStack {
                            SendViewIcon(img: "doc.on.clipboard")
                            Text("Paste")
                                .foregroundStyle(.primary)
                        }
                    }
                    if self.invoiceOrAddress != nil {
                        Button {
                            self.isPresentingPayment = false
                            self.isPresentingPayment = true
                        } label: {
                            HStack {
                                SendViewIcon(img: "arrow.clockwise.circle.fill")
                                Text("Continue Payment")
                                    .foregroundStyle(.primary)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .onAppear {
            cards = manager.fetchCards(forBitcoin: true)
        }
        .onReceive(manager.lightningWallet.listener.$nextEvent, perform: { e in
            if e.contains("paymentSucceed") {
                Task {
                    paymentType = .successful
                    await manager.refresh()
                    cards = manager.fetchCards(forBitcoin: true)
                }
            } else if e.contains("paymentFailed") {
                print("Payment Failed")
                paymentType = .failed
            }
        })
        .onReceive(reader.$scannedString, perform: { e in
            if let nodeId = e {
                print("Handling a Node ID: \(nodeId)")
                parseUpdateUI(input: nodeId)
            }
        })
        .onReceive(manager.bitcoinWallet.$broadcastPayment, perform: { e in
            if e == .succeed {
                Task {
                    paymentType = .successful
                    cards = manager.fetchCards(forBitcoin: true)
                }
            } else if e == .fail {
                paymentType = .failed
            }
        })
        .sheet(isPresented: $isPresentingScanner) {
            CodeScannerView(codeTypes: [.qr], showViewfinder: true, simulatedData: "") { response in
                if case let .success(result) = response {
                    parseUpdateUI(input: result.string)
                }
            }
            .overlay(
                VStack {
                    HStack {
                        Button(action: {
                            isPresentingScanner = false
                            isPresentingPayment = false
                            reader.scan()
                        }, label: {
                            HStack(spacing: 5) {
                                Image(systemName: "lanyardcard.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 10)
                                Text("Tap")
                                    .buttonStyle(.borderedProminent)
                            }
                        })
                        Spacer()
                        if !self.privacyMode {
                            if let balance = cards.first?.fiatBalance {
                                Text("\(symbol)\(balance, specifier: "%.2f")")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        Spacer()
                        Button(action: {
                            if let input = UIPasteboard.general.string {
                                parseUpdateUI(input: input)
                            }
                        }, label: {
                            HStack(spacing: 5) {
                                Image(systemName: "doc.on.clipboard")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 12)
                                Text("Paste")
                                    .buttonStyle(.borderedProminent)
                            }
                        })
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
            )
        }
        .sheet(isPresented: $isPresentingPayment) {
            VStack {
                switch paymentType {
                case .bitcoin:
                    BitcoinSendStackView(bitcoinAmount: self.bitcoinAmount, exchange: manager.exchangeRate, fees: manager.getOnchainFees(), address: self.invoiceOrAddress!)
                case .lnInvoice:
                    if let bitcoinAmount = self.bitcoinAmount {
                        SendInvoiceView(invoice: self.invoiceOrAddress, description: self.description, fiatAmount: self.fiatAmount, bitcoinAmount: self.bitcoinAmount)
                    } else {
                        SendUnspecifiedInvoiceView(exchange: manager.exchangeRate, invoice: self.invoiceOrAddress, description: self.description)
                    }
                case .lnUrl:
                    SendToLnUrlView(exchange: manager.exchangeRate, lnUrl: self.invoiceOrAddress)
                case .keysend:
                    SendToNodeView(exchange: manager.exchangeRate, nodeId: self.invoiceOrAddress)
                case .none:
                    VStack(spacing: 10) {
                        Text(String(localized: "Something went wrong."))
                        Button {
                            isPresentingPayment = false
                            isPresentingScanner = true
                        } label: {
                            Text("Try again?")
                        }
                    }
                case .successful:
                    SuccessfulPaymentView()
                        .onTapGesture {
                            self.isPresentingPayment = false
                        }
                case .failed:
                    FailedPaymentView()
                        .onTapGesture {
                            self.isPresentingPayment = false
                        }
                }
            }
        }
        .presentationDetents([.large])
    }
}

struct SendToQRView_Previews: PreviewProvider {
    static var previews: some View {
        SendToQRView()
            .environmentObject(GlobalStateManager())
    }
}
