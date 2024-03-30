//
//  NumberViewModifier.swift
//  Magma
//
//  Created by Robert Netzke on 2/2/24.
//

//import SwiftUI
//import Combine
//
//struct NumberViewModifier: ViewModifier {
//    
//    @Binding var text: Decimal
//    
//    func body(content: Content) -> some View {
//        content
//            .keyboardType(.decimalPad)
//            .onReceive(Just(text)) { newValue in
////                var tooManyDecimals = false
////                var numbers = "0123456789"
////                let decimalSep: String = Locale.current.decimalSeparator ?? "."
////                numbers.append(decimalSep)
////
////                if let dotIndex = self.text.firstIndex(of: decimalSep.first ?? ".") {
////                    let charactersAfterDot = self.text.suffix(from: self.text.index(after: dotIndex))
////                    if charactersAfterDot.count > 2 {
////                        self.text = String(newValue.dropLast())
////                        tooManyDecimals = true
////                    }
////                }
////
////                if newValue.components(separatedBy: decimalSep).count > 2 {
////                    let filtered = newValue
////                    self.text = String(filtered.dropLast())
////                } else if !tooManyDecimals {
////                    let filtered = newValue.filter { numbers.contains($0) }
////                    self.text = filtered
////                }
//            }
//    }
//}
//
//extension View {
//    func numbersOnly(_ text: Binding<String>) -> some View {
//        self.modifier(NumberViewModifier(text: text))
//    }
//}

