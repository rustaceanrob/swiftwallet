//
//  QRMessageView.swift
//  Magma
//
//  Created by Robert Netzke on 12/16/23.
//

import SwiftUI
import QRCode

//func getQR(c: String) -> QRCode.Document {
//    let qr = QRCode.Document(utf8String: c)
////    qr.logoTemplate = QRCode.LogoTemplate(
////        image: CGImage(),
////        path: CGPath(ellipseIn: CGRect(x: 0.7, y: 0.7, width: 0.30, height: 0.30), transform: nil),
////        inset: 8
////    )
//    qr.design.additionalQuietZonePixels = 5
//    qr.design.shape.eye = QRCode.EyeShape.CorneredPixels(cornerRadiusFraction: 2)
//    qr.design.shape.onPixels = QRCode.PixelShape.CurvePixel()
//    qr.logoTemplate = QRCode.LogoTemplate(image: )
//    return qr
//}

struct QR: View {
    private var invoice: String
    
    init(invoice: String) {
        self.invoice = invoice
    }
    
    var body: some View {
        QRCodeViewUI(content: self.invoice, pixelStyle: QRCode.PixelShape.CurvePixel(), eyeStyle: QRCode.EyeShape.RoundedRect(), additionalQuietZonePixels: 5)
    }
}


struct QRMessageView: View {
    @AppStorage("fiat") private var selectedFiat = "USD"
    @AppStorage("symbol") private var symbol = "$"
    
    @State var didCopy = false
    
    let message: String
    let caption: String
    let amount: String
    let invoiceOrUri: String
    let displayString: String
    let channelOpenFee: Float?
    let paymentTechDescription: String?
    
    private let pasteboard = UIPasteboard.general
    
    init(message: String, caption: String, amount: String, invoiceOrAddress: String, displayString: String, fee: Float?, tech: String?) {
        self.message = message
        self.caption = caption
        self.amount = amount
        self.invoiceOrUri = invoiceOrAddress
        self.displayString = displayString
        self.channelOpenFee = fee
        self.paymentTechDescription = tech
    }
    
    func calcWidth() -> CGFloat {
        return UIScreen.main.bounds.width * 0.80
    }
    
    func truncateInvoice(input: String) -> String {
        return "\(input.prefix(10))...\(input.suffix(5))"
    }
    
    var body: some View {
        FadesView {
            Spacer()
            VStack(alignment: .center, spacing: 2) {
                Text("\(caption) for \(symbol)\(Float(amount)!, specifier: "%.2f")")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("\(self.paymentTechDescription ?? "")")
                    .foregroundColor(.gray)
            }
            Spacer()
            QR(invoice: self.invoiceOrUri)
                .overlay(
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)

                        Image("AppIconTransparent")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45) // Adjust the size of the image as needed
                            }
//                    Image("AppIconTransparent")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 75, height: 75)
                )
                .frame(width: calcWidth(), height: calcWidth())
                .cornerRadius(10)
            
//            QRCodeDocumentUIView(document: getQR(c: self.invoiceOrUri))
//                .frame(width: calcWidth(), height: calcWidth())
//                .cornerRadius(10)
//            Spacer()
//            HStack(alignment: .center) {
//                Button {
//
//                } label: {
//                    HStack {
//                        Image(systemName: "doc.on.clipboard")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 15, height: 15)
//                        Text(String(localized: "Copy"))
//                    }
//                }
//
//            }
            Spacer()
            VStack(alignment: .leading) {
                if let fee = self.channelOpenFee {
                    Divider()
                    VStack(alignment: .leading, spacing: 5) {
                        HStack(spacing: 5) {
//                            Image(systemName: "exclamationmark.circle")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 13)
                            Text("Fee")
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                        Text("A \(symbol)\(fee, specifier: "%.2f") fee will be charged.")
                            .font(.callout)
                            .foregroundColor(Color(.systemGray))
                    }
                }
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 5) {
//                        Image(systemName: "square.and.arrow.up.on.square")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 14)
                        Text("Share")
                            .font(.callout)
                            .fontWeight(.semibold)
                        Spacer()
                        HStack {
                            Button {
                                pasteboard.string = self.displayString
                            } label: {
                                HStack {
                                    Image(systemName: "doc.on.clipboard")
                                }
                            }
                            ShareLink("", item: self.invoiceOrUri)
                        }
//                        Button {
//                            didCopy = true
//                            pasteboard.string = invoiceOrAddress
//                        } label: {
//                            Image(systemName: didCopy ? "checkmark.circle": "doc.on.clipboard")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 15)
//                        }
                    }
                    Text(truncateInvoice(input: self.displayString))
                        .font(.callout)
                        .foregroundColor(Color(.systemGray))
                }
                Divider()
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 5) {
//                        Image(systemName: "lightbulb")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 14)
                        Text("Tip")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    Text(message)
                        .font(.caption)
                        .foregroundColor(Color(.systemGray))
                }
            }
            .frame(width: calcWidth())
            Spacer()
        }
        .padding(.bottom, 15)
    }
}

struct QRMessageView_Preview: PreviewProvider {
    static var previews: some View {
        QRMessageView(message: "This transaction will settle instantly using a technology called Lightning. You will occasionally pay a small fee to receive Bitcoin over Lightning, but you will pay near zero fees when you spend it later.", caption: "Lightning payment", amount: "10", invoiceOrAddress: "lnbc200u1pjh74tddpdf9h8vmmfvdjjqen0wgsryvpqxqcrqgpsxqczqmtnv968xpp588d24sjsfd03sazgpry8ghg2gufp9le9we9av8qajaufzl4tyakqxqrrsssp5hh2mtwymdlk66tvs6hmfe0jfdcv7v0ajccsf45fu3eh27crktqdq9qrsgqcqzysrzjqtypret4hcklglvtfrdt85l3exc0dctdp4qttmtcy5es3lpt6uts6qqqqyqqqqqqqqqqqqlgqqqqqzsqygmxpp3zxsnq586hssy9lmarx2ve3x2fapkp38fr62u850g8ckc425lnvynygaf8pqsk3gpka7d7ju46dvmkf53n52atz5ksjlz7n0s3gpe4v9pa", displayString: "lnbc200u1pjh74tddpdf9h8vmmfvdjjqen0wgsryvpqxqcrqgpsxqczqmtnv968xpp588d24sjsfd03sazgpry8ghg2gufp9le9we9av8qajaufzl4tyakqxqrrsssp5hh2mtwymdlk66tvs6hmfe0jfdcv7v0ajccsf45fu3eh27crktqdq9qrsgqcqzysrzjqtypret4hcklglvtfrdt85l3exc0dctdp4qttmtcy5es3lpt6uts6qqqqyqqqqqqqqqqqqlgqqqqqzsqygmxpp3zxsnq586hssy9lmarx2ve3x2fapkp38fr62u850g8ckc425lnvynygaf8pqsk3gpka7d7ju46dvmkf53n52atz5ksjlz7n0s3gpe4v9pa", fee: 1, tech: "Instant Bitcoin transaction")
    }
}
