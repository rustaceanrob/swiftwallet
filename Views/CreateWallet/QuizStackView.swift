//
//  QuizStackView.swift
//  Magma
//
//  Created by Robert Netzke on 1/6/24.
//

import SwiftUI

struct QuizStackView: View {
    @State var passedQuiz: Bool = false
    var body: some View {
        if !passedQuiz {
            SeedPhraseView(passedQuiz: $passedQuiz)
        } else {
            WalletConfirmationView()
        }
    }
}

struct QuizStackView_Previews: PreviewProvider {
    static var previews: some View {
        QuizStackView()
            .environmentObject(GlobalStateManager())
    }
}
