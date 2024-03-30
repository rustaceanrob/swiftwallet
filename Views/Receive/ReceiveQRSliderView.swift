//
//  ReceiveQRSlider.swift
//  Magma
//
//  Created by Robert Netzke on 12/17/23.
//

import SwiftUI

struct ReceiveQRSliderView: View {
    
    let dollarAmount: String
    let lnInvoice: LnInvoiceRequestModel
    let bitcoinUri: BitcoinPaymentRequestModel
    
    init(fiat: String, lnInvoice: LnInvoiceRequestModel, btcReq: BitcoinPaymentRequestModel) {
        self.dollarAmount = fiat
        self.lnInvoice = lnInvoice
        self.bitcoinUri = btcReq
    }
    
    var body: some View {
        TabView {
            QRMessageView(message: "This transaction will settle instantly using a technology called Lightning. You will occasionally pay a small fee to receive Bitcoin over Lightning, but you will pay near zero fees when you spend it later.", caption: "Lightning payment", amount: self.dollarAmount, invoiceOrAddress: self.lnInvoice.bolt11, displayString: self.lnInvoice.bolt11, fee: self.lnInvoice.feeInFiat, tech: "Instant Bitcoin transaction")
                .transition(.slide)
            QRMessageView(message: "Bitcoin is typically used for large payments. Settlement times are not instant, and sending payments over Bitcoin directly can result in high fees. However, it is free to receive Bitcoin payments.", caption: "Bitcoin payment", amount: self.dollarAmount, invoiceOrAddress: self.bitcoinUri.uri, displayString: self.bitcoinUri.address, fee: nil, tech: "Best for saving")
                .transition(.slide)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct ReceiveQRSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiveQRSliderView(fiat: "$100", lnInvoice: LnInvoiceRequestModel(bolt11: "lnbc200u1pjh74tddpdf9h8vmmfvdjjqen0wgsryvpqxqcrqgpsxqczqmtnv968xpp588d24sjsfd03sazgpry8ghg2gufp9le9we9av8qajaufzl4tyakqxqrrsssp5hh2mtwymdlk66tvs6hmfe0jfdcv7v0ajccsf45fu3eh27crktqdq9qrsgqcqzysrzjqtypret4hcklglvtfrdt85l3exc0dctdp4qttmtcy5es3lpt6uts6qqqqyqqqqqqqqqqqqlgqqqqqzsqygmxpp3zxsnq586hssy9lmarx2ve3x2fapkp38fr62u850g8ckc425lnvynygaf8pqsk3gpka7d7ju46dvmkf53n52atz5ksjlz7n0s3gpe4v9pa"), btcReq: BitcoinPaymentRequestModel(uri: "bitcoin:", address: ""))
    }
}
