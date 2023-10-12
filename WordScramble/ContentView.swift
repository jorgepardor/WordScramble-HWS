//
//  ContentView.swift
//  WordScramble
//
//  Created by Jorge Pardo on 4/10/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .disableAutocorrection(true)
                }
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                Button("New Game", action: startGame)
            }
            .safeAreaInset(edge: .bottom) {
                Text("Score \(score)")
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 2 else {
            wordError(title: "La palabra '\(answer)' es muy corts", message: "Las palabras deben tener al menos 3 letras")
            return
        }
        
        guard answer != rootWord else { 
            wordError(title: "Ehm.. no!", message: "No puedes utilizar la palabra proporcionada como respuesta")
            return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Ya escribiste la palabra '\(answer)'", message: "No puedes repetir palabras")
            return
        }
        
        guard isPosible(word: answer) else {
            wordError(title: "La palabra '\(answer)' no esta contenida en \(rootWord)", message: "Solo los caracteres con la misma acentuación son válidos o alguna letra no existe en la palabra")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "La palabra '\(answer)' no existe", message: "Solo son válidas las palabras incluidas en el diccionario")
            return
        }
        
        withAnimation{
            usedWords.insert(answer, at: 0)

        }
        newWord = ""
        score += answer.count
    }
    
    func startGame() {
        newWord = ""
        score = 0
        usedWords.removeAll()
        
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        
        fatalError("Could not load start.txt from Bundle")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPosible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "es_ES")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
