//
//  SendInvoiceView.swift
//  Magma
//
//  Created by Robert Netzke on 1/25/24.
//

import SwiftUI

struct SendInvoiceView: View {
    
    @EnvironmentObject var manager: GlobalStateManager
    
    private var invoiceOrAddress: String?
    private var description: String?
    private var fiatAmount: Float?
    private var bitcoinAmount: Float?
    @State private var sendingPayment: Bool = false
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") var symbol = "$"
    
    func truncateInvoice(input: String) -> String {
        return "\(input.prefix(10))...\(input.suffix(5))"
    }
    
    init(invoice: String?, description: String?, fiatAmount: Float?, bitcoinAmount: Float?) {
        self.invoiceOrAddress = invoice
        self.description = description
        self.fiatAmount = fiatAmount
        self.bitcoinAmount = bitcoinAmount
    }
    
    var body: some View {
        FadesView {
            VStack(spacing: 10) {
                Spacer()
                VStack(spacing: 10) {
                    Text("Confirm Payment")
                        .font(.title)
                    if let amount = fiatAmount {
                        Text("\(symbol)\(amount, specifier: "%.2f")")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        }
                }
                Spacer()
                if let description = self.description {
                    if description != "" {
                        Divider()
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 5) {
                                Text("Description")
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            Text("\(description)")
                                .font(.callout)
                                .foregroundColor(Color(.systemGray))
                        }
                    }
                }
                if let invoice = self.invoiceOrAddress {
                    Divider()
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 5) {
                            Text("Share")
                                .font(.callout)
                                .fontWeight(.semibold)
                            Spacer()
                            ShareLink("", item: invoice)
                        }
                        Text(truncateInvoice(input: invoice))
                            .font(.callout)
                            .foregroundColor(Color(.systemGray))
                    }
                }
                if let bitcoin = self.bitcoinAmount {
                    Divider()
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 5) {
                            Text("Bitcoin")
                                .font(.callout)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        Text("\(bitcoin, specifier: "%.8f")")
                            .font(.callout)
                            .foregroundColor(Color(.systemGray))
                    }
                }
                Divider()
                Spacer()
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
                                    await manager.lightningWallet.sendLightningInvoicePayment(fiatAmount: nil, paymentType: .lnInvoice, userDescription: nil)
                                    print("Status updated")
                                }
                            }
                    }
                }
            }
        }
        .padding()
    }
}

struct SendInvoiceView_Previews: PreviewProvider {
    static var previews: some View {
        SendInvoiceView(invoice: "lnbc200u1pjmg2srsp527hu78kgd0n0yhejcqyeh4fsak89kh27n56wdwlqfrsmuptrmm6spp5t9g7e0ha2rukmq7k6m9kv8da729c8dpys0jlnmr6xl3ty24yxk3sdpdf9h8vmmfvdjjqen0wgsryvpqxqcrqgpsxqczqmtnv968xcqzysrzjqtypret4hcklglvtfrdt85l3exc0dctdp4qttmtcy5es3lpt6uts6lzg9r0tt5j9xyqqqqqqqqqqqqqqyg9qxpqysgqcrtvvs299z6d0yxg5z2pqmnplk5u7mjr8mlj0ddx76trl23hvafkxpy4hkelafhgs947sq3yyeudae4a38g809d9tyyjd05fe400txgqkxzhlq", description: "Soccer game", fiatAmount: 2.0, bitcoinAmount: 0.00002500)
            .environmentObject(GlobalStateManager())
    }
}
