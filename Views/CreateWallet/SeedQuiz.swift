//
//  SeedQuiz.swift
//  Magma
//
//  Created by Robert Netzke on 12/18/23.
//

import SwiftUI

struct SeedQuiz: View {
    
    var secrets: [String]
    @State var word: String = ""
    @Binding var passedQuiz: Bool
    @FocusState var wordIsFocused: Bool
    @State private var numCorrect = 0
    @State private var currentIndex = 6
    private var formattedNumber = ""
    private let formatter = NumberFormatter()

    
    init(seed: [String], didPass: Binding<Bool>) {
        formatter.numberStyle = .spellOut
        secrets = seed
        self._passedQuiz = didPass
        
    }
    
    func getFormattedNumber(num: Int) -> String {
        return formatter.string(from: num + 1 as NSNumber) ?? ""
    }
    
    var body: some View {
        VStack(alignment:.center, spacing: 20) {
            Text("What was word \(getFormattedNumber(num: currentIndex))?")
                .font(.headline)
            TextField("Word", text: $word)
                .onChange(of: word, perform: { newValue in
                    if newValue == secrets[currentIndex] {
                        self.numCorrect = self.numCorrect + 1
                        if self.numCorrect > 5 {
                            passedQuiz = true
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                word = ""
                                self.currentIndex = self.currentIndex + 1
                            }
                        }
                    }
                })
            .focused($wordIsFocused)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(word == secrets[currentIndex] ? Color.green : Color(.placeholderText), lineWidth: 2)
                )
            Spacer()
//            Image(systemName: "questionmark.square.dashed")
//                .resizable()
//                .frame(width: 150, height: 150)
//                .scaledToFit()
//                .foregroundColor(.accentColor)
//            Spacer()
        }
        .padding(40)
    }
}

struct SeedQuiz_Previews: PreviewProvider {
    @State static var passedQuiz: Bool = false
    static var previews: some View {
        SeedQuiz(seed: ["abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "abandon", "about"], didPass: $passedQuiz)
    }
}
