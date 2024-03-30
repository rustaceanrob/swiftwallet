//
//  HomeView.swift
//  Magma
//
//  Created by Robert Netzke on 12/16/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: GlobalStateManager
    @AppStorage("card") private var selectedCardStyle = "magma"
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") private var symbol = "$"
    @AppStorage("privacyMode") var privacyMode: Bool = false
    
    @State var cards: [CardModel] = []
    @State var txs: [TransactionListItemModel] = []
    
    init() {
        let converter = Converter()
        symbol = converter.tickerToSymbol(ticker: selectedFiat)
    }
    
    var body: some View {
        NavigationStack() {
            VStack {
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
//                                .padding(.bottom, 30)
                        ).cornerRadius(10)
                        .padding()
                    }
                }
                .shadow(color: Color(.systemGray), radius:  2)
                .frame(height: 220)
                .navigationTitle("Wallet")
                .tabViewStyle(.page)
                .onTapGesture {
                    privacyMode.toggle()
                }
                
                VStack(alignment: .leading) {
                    HStack {
//                        Image(systemName: "list.dash")
                        Text("Latest Transactions")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .padding(.horizontal)
                    Divider()
                    if (txs.count < 1) {
                        Text("No payments yet")
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 100)
                    }
                    List {
                        ForEach(txs, id: \.self) { transaction in
                            HStack(spacing: 10) {
                                Image(systemName: transaction.onChain ? "bitcoinsign": "bolt.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.accentColor)
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text("\(transaction.wasSent ? "Sent": "Received" )")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.accentColor)
                                        if privacyMode {
                                            Text("********")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .blur(radius: 2)
                                        } else {
                                            Text("\(transaction.amount, specifier: "%.8f") Bitcoin")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                        Text("\(transaction.wasConfirmed ? "Confirmed": "Unconfirmed")")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        if let fiat = transaction.fiatAmount {
                                            if !privacyMode {
                                                Text("\(transaction.wasSent ? "-": "" )\(symbol)\(fiat, specifier: "%.2f")")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                            } else {
                                                Text("**")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .blur(radius: 2)
                                            }
                                        }
                                        Text("\(transaction.detail)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: SettingsView(), label: {
                        Image(systemName: "gear")
                            .foregroundColor(Color.primary)
                    })
                }
//                ToolbarItem {
//                    Image(systemName: "cart")
//                        .foregroundColor(Color.primary)
//                }
//                ToolbarItem() {
//                    Image(systemName: "qrcode")
//                        .foregroundColor(Color.primary)
//                }
            }
        }
        .onAppear {
            Task {
                cards = manager.fetchCards(forBitcoin: true)
                txs = manager.fetchTxHistory()
            }
        }
        .refreshable {
            await manager.refreshAll()
            cards = manager.fetchCards(forBitcoin: true)
            txs = manager.fetchTxHistory()
        }
//        .onReceive(manager.bitcoinWallet.$updated, perform: { e in
//            print("Bitcoin wallet updated.")
//        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(GlobalStateManager())
    }
}

