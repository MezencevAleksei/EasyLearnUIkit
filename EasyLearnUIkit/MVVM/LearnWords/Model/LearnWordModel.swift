//
//  LearnWordModel.swift
//  EasyLearn
//
//  Created by alex on 02.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

enum TrainingType {
    case watchAndRemember
    //перевод на родной язык
    case nativeLanguageTranslation
    //Перевод на иностранный язык
    case translationIntoForeignLanguage
    // перевод по буквам
    case translationByLetters
    
    static func getFirstType()->TrainingType{
        return .watchAndRemember
    }
    
    func next()-> TrainingType?{
        if self == .watchAndRemember {
            return .nativeLanguageTranslation
        }else if self == .nativeLanguageTranslation{
            return .translationIntoForeignLanguage
        }else if self == .translationIntoForeignLanguage{
            return .translationByLetters
        }else if self == .translationByLetters{
            return nil
        }
        return nil
    }
}



final class Training{
    var typeOfTraining: TrainingType = .watchAndRemember
    var trainingWords = [TrainingWord]()
    private let words: [WordModel]
    var currentWord: TrainingWord?
    var trainingIsEnd = false
    private let answerCount = 6
    private var curentWordByLetters: String = ""
    private var curentWordByLettersRightSibolsAdd: Int = 0
    
    init(words: [WordModel]){
        self.words = words
    }
    
    func start()-> TrainingWord{
        self.generateTrainingWords()
        self.currentWord = trainingWords[0]
        return self.currentWord!
    }
    
    func next()->TrainingWord?{
        if let next = getNextWordForTraining(){
            self.currentWord = next
            return next
        }else {
            if let nextType = typeOfTraining.next(){
                self.typeOfTraining = nextType
                return self.start()
            }else {
                return nil
            }
        }
    }
    
    func addLettersToWord(simbol: String, isEnd: inout Bool)->Bool{
        var result = false
        if let _currentWord = self.currentWord{
            let cWord = _currentWord.wordModel.word
            let str = curentWordByLetters + simbol
            let countLettersForRemove = (cWord.count - str.count)
            let cWordCut = removeRightSimbols(string: cWord, amountSimbols: countLettersForRemove)
            if cWordCut == str{
                result = true
            }
            if (curentWordByLetters + simbol) == cWord {
                isEnd = true
            }
        }
        if result {
            curentWordByLetters = curentWordByLetters + simbol
        }
       
        if isEnd {
            curentWordByLetters = ""
        }
        return result
    }
    
    private func removeRightSimbol(string: String) -> String?{
        let startIndex = string.startIndex
        let endIndex   = string.endIndex
        if string.count > 0 {
            let negativeIndex = string.index(before: endIndex)
            let range = startIndex ..< negativeIndex
            return String(string[range])
        }
        return string
    }

    private func removeRightSimbols(string: String, amountSimbols: Int)->String?{
        var amount = amountSimbols
        var currentString:String? = string
        while amount > 0 {
            if currentString != nil && currentString != ""{
                currentString = removeRightSimbol(string: currentString!)
                amount = amount - 1
            }
        }
        return currentString
    }
    

    private func generateTrainingWords(){
        self.trainingWords.removeAll()
        for word in words {
            let mainWord = getMainWord(word)
            
            let answerWordsArray = getAnswerArray(word:word, words: words)
            
            let tWord = TrainingWord(word: word, typeOfTraining: self.typeOfTraining, mainWord: mainWord, answerWords: answerWordsArray)
            trainingWords.append(tWord)
        }
    }
    
    private func getMainWord(_ word: WordModel)->String{
        var result: String = ""
        switch self.typeOfTraining {
        case .nativeLanguageTranslation:
            result = word.word
        case .translationByLetters:
            result = word.translateWords[0].word
        case .translationIntoForeignLanguage:
            result = word.translateWords[0].word
        case .watchAndRemember:
            result = word.word
        }
        return result
    }

    private func getAnswerArray(word: WordModel, words: [WordModel])->[AnswerStruct]{
        var result :[AnswerStruct]
        switch self.typeOfTraining {
        case .nativeLanguageTranslation:
            var array = [AnswerStruct]()
            //в начале вставляем правильный ответ потом остальные
            array.append(AnswerStruct(word: word.translateWords[0].word, rightResponse: true, number: 1))
            var index = 2
            for _word in words{
                if _word.word != word.word && index <= self.answerCount {
                    array.append(AnswerStruct(word: _word.translateWords[0].word, rightResponse: false, number: index))
                    index += 1
                }
            }
            array.shuffle()
            result = array
        case .translationByLetters:
            // сделаем массив из букв
            let lettersArray = word.word.map { String($0) }
            var array = [AnswerStruct]()
            var index = 1
            for letter in lettersArray {
                if index <= self.answerCount {
                    array.append(AnswerStruct(word: letter, rightResponse: false, number: index))
                    index += 1
                }else{
                    break
                }
            }
            array.shuffle()
            result = array
        case .translationIntoForeignLanguage:
            var array = [AnswerStruct]()
            //в начале вставляем правильный ответ потом остальные
            array.append(AnswerStruct(word: word.word, rightResponse: true, number: 1))
            var index = 2
            for _word in words{
                if _word.word != word.word && index <= self.answerCount {
                    array.append(AnswerStruct(word: _word.word, rightResponse: false, number: index))
                    index += 1
                }
            }
            array.shuffle()
            result = array
        case .watchAndRemember:
            
            var array = [AnswerStruct]()
            //в начале вставляем правильный ответ потом остальные
            array.append(AnswerStruct(word: "Помню", rightResponse: true, number: 1))
            array.append(AnswerStruct(word: "Не помню", rightResponse: false, number: 2))
            result = array
        }
        return result

    }
    
    private func setNextTrainingType(){
        if let nextTypeOfTrain = self.typeOfTraining.next(){
            self.typeOfTraining = nextTypeOfTrain
        }else {
            self.trainingIsEnd = true
        }
    }
    
    
    
    
    private func getNextWordForTraining()->TrainingWord?{
        if self.trainingIsEnd {return nil}
        
        guard let cWord = self.currentWord else {return nil}
            
        var findedWord = false
        for w in trainingWords{
            if !findedWord && w.mainWord == cWord.mainWord{
                findedWord = true
            }else if findedWord{
                return w
            }
        }
        return nil
    }
    
    
}


struct AnswerStruct{
    let word: String
    let rightResponse: Bool
    let number: Int
}

final class TrainingWord{
    
    let wordModel : WordModel
    let typeOfTraining: TrainingType
    let mainWord: String
    let answerWords: [AnswerStruct]
    
    init(word: WordModel, typeOfTraining: TrainingType, mainWord: String,  answerWords: [AnswerStruct]){
        self.typeOfTraining = typeOfTraining
        self.wordModel   = word
        self.mainWord    = mainWord
        self.answerWords = answerWords
    }
    
    func getJobDescription()->String{
        var result = ""
        switch self.typeOfTraining {
        case .nativeLanguageTranslation:
            result = "Выберете правильный перевод"
        case .translationByLetters:
            result = "Соберите слово из букв"
        case .translationIntoForeignLanguage:
            result = "Выберете правильный перевод"
        case .watchAndRemember:
            result = "Помните ли вы перевод слова?"
        }
        return result
    }
    
    func getAnswerByIndex(_ index:Int)->String{
        var result = ""
        for answer in answerWords{
            if answer.number == index {
                result = answer.word
            }
        }
        return result
    }
    
    func checkRightAnswer(number: Int)-> Bool{
        var result = false
        for answer in answerWords{
            if answer.number == number && answer.rightResponse{
                result = true
            }
        }
        return result
    }
    
}
