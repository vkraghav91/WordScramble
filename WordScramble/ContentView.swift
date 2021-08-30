//
//  ContentView.swift
//  WordScramble
//
//  Created by Varun Kumar Raghav on 21/08/21.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var score = 0.0
    
    // error alert properties
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("Enter a new Word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                List(usedWords, id: \.self){
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
                Text("Your score is : \(score, specifier: "%.2f")")
                    .foregroundColor(.blue)
            }.navigationBarTitle(rootWord)
            .navigationBarItems(trailing: Button("Restart Game"){
                usedWords.removeAll()
                newWord = ""
                score = 0.0
                startGame()
            } )
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError){
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("Ok")))
                
            }
        }
    }
    // Loding game data
    func startGame() {
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    // playing game and inserting words and validating word entered
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else {
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        score = score + Double((usedWords.count + newWord.count)/(usedWords.count))
        newWord = ""
    }
    
    // validations
    func isOriginal(word: String) -> Bool {
        if !usedWords.contains(word){
            return true
        }else{
            score -= 1
            return false
            
        }
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                score -= 1
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        if !(word.count < 3) && !word.contains(rootWord){
            
            let checker = UITextChecker()
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            if misspelledRange.location == NSNotFound{
                return true
            }else{
                score -= 1
                return false
                
            }
        }
        else{
            score -= 1
            return false
        }
    }
    
    //Error alert method
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
