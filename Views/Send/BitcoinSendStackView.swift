//
//  BitcoinSendStackView.swift
//  Magma
//
//  Created by Robert Netzke on 2/14/24.
//

import SwiftUI

struct BitcoinSendStackView: View {
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") private var symbol = "$"
    
    private var address: String
    private var feeList: FeeDigest?
    private var exchange: Float?
    private var bitcoinAmount: Float?
    
    init(bitcoinAmount: Float? = nil, exchange: Float?, fees: FeeDigest?, address: String) {
        self.feeList = fees
        self.address = address
        self.exchange = exchange
        self.bitcoinAmount = bitcoinAmount
    }
    
    var body: some View {
        NavigationStack {
            if let feeList = self.feeList {
                VStack(alignment: .leading) {
                    Spacer()
                    Text("Select a fee")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding()
                    Text("Bitcoin transactions require a fee to spend. If you are not sending Bitcoin to yourself, ask your recipient if they accept Lightning Network payments.")
                        .font(.callout)
                        .foregroundColor(.gray)
                        .padding()
                    Divider()
                    List {
                        NavigationLink(destination: PayBitcoinView(bitcoinAmount: self.bitcoinAmount, exchange: self.exchange, fee: feeList.urgent.0, address: self.address), label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(String(localized: "Urgent"))
                                    Text(String(localized: "Around 10 minutes"))
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                HStack {
                                    Text("Around \(symbol)\(feeList.urgent.1, specifier: "%.2f")")
                                }
                            }
                        })
                        NavigationLink(destination: PayBitcoinView(bitcoinAmount: self.bitcoinAmount, exchange: self.exchange, fee: feeList.halfHour.0, address: self.address), label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(String(localized: "Timely"))
                                    Text(String(localized: "Around 30 minutes"))
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                HStack {
                                    Text("Around \(symbol)\(feeList.halfHour.1, specifier: "%.2f")")
                                }
                            }
                        })
                        NavigationLink(destination: PayBitcoinView(bitcoinAmount: self.bitcoinAmount, exchange: self.exchange, fee: feeList.hour.0, address: self.address), label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(String(localized: "Economic"))
                                    Text(String(localized: "Around one hour"))
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                HStack {
                                    Text("Around \(symbol)\(feeList.hour.1, specifier: "%.2f")")
                                }
                            }
                        })
                        NavigationLink(destination: PayBitcoinView(bitcoinAmount: self.bitcoinAmount, exchange: self.exchange, fee: feeList.economy.0, address: self.address), label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(String(localized: "No preference"))
                                    Text(String(localized: "24 hours or more"))
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                HStack {
                                    Text("Around \(symbol)\(feeList.economy.1, specifier: "%.2f")")
                                }
                            }
                        })
                    }
                    .listStyle(.plain)
                }
            } else {
                Text("An error occured.")
            }
        }
    }
}

struct BitcoinSendStackView_Previews: PreviewProvider {
    static var previews: some View {
        BitcoinSendStackView(exchange: nil, fees: FeeDigest(urgent: (29, 2.09), halfHour: (27, 1.30), hour: (25, 0.90), economy: (12, 0.26)), address: "")
    }
}
