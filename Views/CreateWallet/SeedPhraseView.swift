//
//  SeedPhraseView.swift
//  Magma
//
//  Created by Robert Netzke on 12/18/23.
//

import SwiftUI

struct SeedPhraseView: View {
    
    @Binding var passedQuiz: Bool
    @EnvironmentObject var manager: GlobalStateManager
    @State private var showQuiz: Bool = false
    @State var numCorrect = 0
    @State private var word: String = ""
    @FocusState private var wordIsFocused: Bool
    @State private var quiz: [String] = []

    var body: some View {
        ZStack {
            VStack {
                VStack(alignment: .leading) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "lock.doc")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20)
                                .foregroundColor(.accentColor)
                            Text("Your Recovery Phrase")
                                .font(.title)
                                .fontWeight(.semibold)
                        }
                        Text("After you write these words down in order, you will have a short quiz to make sure they are correct.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }.padding(.horizontal)
                    List {
                        ForEach(self.quiz.indices, id: \.self) { number in
                            HStack {
                                Text("\(number + 1).")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.gray)
                                Text("\(self.quiz[number])")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                .padding()
                Button {
                    showQuiz.toggle()
                } label: {
                    Text("Ready")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(20)
            }
            
        }
        .blur(radius: showQuiz ? 20 : 0)
        .sheet(isPresented: $showQuiz) {
            SeedQuiz(seed: self.quiz, didPass: $passedQuiz)
                .presentationDetents([.height(300)])
        }
        .onAppear {
            self.quiz = manager.requestSeed()
        }
    }
}

struct SeedPhraseView_Previews: PreviewProvider {
    @State static var passedQuiz: Bool = false
    static var previews: some View {
        SeedPhraseView(passedQuiz: $passedQuiz)
            .environmentObject(GlobalStateManager())
    }
}
