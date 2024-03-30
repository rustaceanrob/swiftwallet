//
//  FinalMessageView.swift
//  Magma
//
//  Created by Robert Netzke on 12/18/23.
//

import SwiftUI

enum WordFields: Hashable {
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case eleven
    case twelve
}

enum RecoveryCases {
    case recovering
    case invalid
    case loading
}

struct FinalMessageView: View {
    
    @EnvironmentObject var manager: GlobalStateManager
    
    @FocusState private var focusedField: WordFields?
    @State var isAttemptingRecovery: Bool = false
    @State var needsMore: Bool = false
    @State var status: RecoveryCases = .recovering
    
    // seed words
    @State var word1: String = ""
    @State var word2: String = ""
    @State var word3: String = ""
    @State var word4: String = ""
    @State var word5: String = ""
    @State var word6: String = ""
    @State var word7: String = ""
    @State var word8: String = ""
    @State var word9: String = ""
    @State var word10: String = ""
    @State var word11: String = ""
    @State var word12: String = ""
    
    func handleWordSubmission() async {
        let words = [word1, word2, word3, word4, word5, word6, word7, word8, word9, word10, word11, word12]
        let lowered = words.map { $0.lowercased() }
        for word in lowered {
            if word == "" {
                needsMore = true
                DispatchQueue.main.async {
                    sleep(1)
                    needsMore = false
                }
                return
            }
        }
        let mnemonic = lowered.joined(separator: " ")
        let successful = await manager.userRecoveredWallet(mnenomic: mnemonic)
        if !successful {
            self.status = .invalid
            self.word1 = ""
            self.word2 = ""
            self.word3 = ""
            self.word4 = ""
            self.word5 = ""
            self.word6 = ""
            self.word7 = ""
            self.word8 = ""
            self.word9 = ""
            self.word10 = ""
            self.word11 = ""
            self.word12 = ""
        }
    }
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            WelcomeMessageView(title: String(localized: "Ready?"), caption: String(localized: "When you have your pen and paper, you are ready to create a new wallet."), imgRef: "rectangle.and.pencil.and.ellipsis")
            VStack(spacing: 20) {
                Button {
                    Task {
                        await manager.getNewWallet()
                    }
                } label: {
                    Text(String(localized: "Set up a new wallet"))
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 20)
                
                Button {
                    isAttemptingRecovery.toggle()
                } label: {
                    Text(String(localized: "Use recovery phrase"))
                        .font(.callout)
                }
            }
            .padding(.top, 50)
            .padding(.bottom, 100)
            .sheet(isPresented: $isAttemptingRecovery) {
                switch self.status {
                case .invalid:
                    VStack(spacing: 5) {
                        Text("That phrase didn't work")
                        Button {
                            self.status = .recovering
                        } label: {
                            Text("Try again?")
                        }
                    }
                case .loading: LoadingScreen()
                case .recovering:
                    Form {
                        Section(header: Text(String(localized: "Recovery Phrase"))) {
                            Group {
                                TextField("Word one", text: $word1)
                                    .badge(1)
                                    .focused($focusedField, equals: .one)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .two
                                    }
                                TextField("Word two", text: $word2)
                                    .badge(2)
                                    .focused($focusedField, equals: .two)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .three
                                    }
                                TextField("Word three", text: $word3)
                                    .badge(3)
                                    .focused($focusedField, equals: .three)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .four
                                    }
                                TextField("Word four", text: $word4)
                                    .badge(4)
                                    .focused($focusedField, equals: .four)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .five
                                    }
                                TextField("Word five", text: $word5)
                                    .badge(5)
                                    .focused($focusedField, equals: .five)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .six
                                    }
                                TextField("Word six", text: $word6)
                                    .badge(6)
                                    .focused($focusedField, equals: .six)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .seven
                                    }
                            }
                            Group {
                                TextField("Word seven", text: $word7)
                                    .badge(7)
                                    .focused($focusedField, equals: .seven)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .eight
                                    }
                                TextField("Word eight", text: $word8)
                                    .badge(8)
                                    .focused($focusedField, equals: .eight)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .nine
                                    }
                                TextField("Word nine", text: $word9)
                                    .badge(9)
                                    .focused($focusedField, equals: .nine)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .ten
                                    }
                                TextField("Word ten", text: $word10)
                                    .badge(10)
                                    .focused($focusedField, equals: .ten)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .eleven
                                    }
                                TextField("Word eleven", text: $word11)
                                    .badge(11)
                                    .focused($focusedField, equals: .eleven)
                                    .submitLabel(.next)
                                    .onSubmit {
                                        focusedField = .twelve
                                    }
                                TextField("Word twelve", text: $word12)
                                    .badge(12)
                                    .focused($focusedField, equals: .twelve)
                                    .submitLabel(.done)
                                    .onSubmit {
                                        self.status = .loading
                                        Task {
                                            await handleWordSubmission()
                                        }
                                    }
                            }
                        }
                        Button {
                            self.status = .loading
                            Task {
                                await handleWordSubmission()
                            }
                        } label: {
                            HStack(alignment: .center) {
                                Text("Submit")
                            }
                        }
                    }
                    .onAppear {
                        self.focusedField = .one
                    }
                }
            }
        }
    }
}

struct FinalMessageView_Previews: PreviewProvider {
    static var previews: some View {
        FinalMessageView()
    }
}
