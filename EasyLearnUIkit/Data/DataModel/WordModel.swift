//
//  WordModel.swift
//  EasyLearn
//
//  Created by alex on 24.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class WordModel {
   
    var word: String
    var wordLanguge: String
    var translateWords: [(word:String,partOfSpeech: String?)]
    var wordTranslateLanguge: String
    var dateAdd: Date?
    var transcription: String?
    var partOfSpeech: String?
    
    init(word: String, translateWords: [String], langugeFrom: String, LangugeTo: String, date: Date?, transcription: String? = nil, partOfSpeech: String? = nil){
        self.word = word
        self.wordLanguge = langugeFrom
        self.wordTranslateLanguge = LangugeTo
        self.dateAdd = date
        self.transcription = transcription
        self.partOfSpeech = partOfSpeech
        self.translateWords = [(word:String,partOfSpeech: String?)]()
        if translateWords.count > 0 {
            for trWord in translateWords{
                let tr:(word:String, partOfSpeech: String?) = (trWord,  nil)
                self.translateWords.append(tr)
            }
        }
    }
    
    init(word: String, translateWordsTupls: [(word:String,partOfSpeech: String?)], langugeFrom: String, LangugeTo: String, date: Date?, transcription: String? = nil, partOfSpeech: String? = nil){
        self.word = word
        self.wordLanguge = langugeFrom
        self.wordTranslateLanguge = LangugeTo
        self.dateAdd = date
        self.transcription = transcription
        self.partOfSpeech = partOfSpeech
        self.translateWords = translateWordsTupls
    }
    
    init(decodedResponse: ResponseYandexDict, langugeFrom: String, LangugeTo: String){
        self.word = ""
        self.transcription = ""
        self.translateWords = [(word:String,partOfSpeech: String?)]()
        self.dateAdd = Date()
        self.wordLanguge = langugeFrom
        self.wordTranslateLanguge = LangugeTo
        
        if let dictEntriesArray = decodedResponse.dictEntriesArray{
            if dictEntriesArray.count > 0 {
                let mainDictEntrie = dictEntriesArray[0]
                //слово которое переводим
                if let text = mainDictEntrie.text{
                    self.word = text
                }
                
                //транскрипция
                if let transcription = mainDictEntrie.transcription{
                    self.transcription = transcription
                }
                
                //часть речи
                if let partOfSpeech = mainDictEntrie.partOfSpeech{
                    self.partOfSpeech = partOfSpeech
                }
                
                //массив слов перевода
                
                if let translationsArray = mainDictEntrie.translationsArray{
                    
                    for trWord in translationsArray{
                        if let trWordsText = trWord.text{
                            
                            var _partOfSpeech:String? = nil
                            if let _ps = trWord.partOfSpeech{
                                _partOfSpeech = _ps
                            }
                            let tr:(word:String, partOfSpeech: String?) = (trWordsText,  _partOfSpeech)
                            self.translateWords.append(tr)
                        }
                    }
                }
                
                
            }
        }
        
        
        
    }
    
    
    func wordTranslateString()->String {
        var word = ""
        for trWord in translateWords {
            word = word + (word == "" ? "":", ") + trWord.word
        }
        return word
    }
    
    func getTranslateText()-> NSMutableAttributedString{
        let firstMeaningAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 22), .foregroundColor: UIColor.white]
        let entryNameAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.white]
        let transcriptionAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.middleGray]
        let posAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightYellow]
        let counterAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.middleGray]
        let meaningAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.brightYellow]
                
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 22, options: [:])]
        paragraphStyle.headIndent = 22
        
        var firstMeaningString = ""
        
        if translateWords.count > 0 {
            firstMeaningString = translateWords[0].word
        }else {
            return NSMutableAttributedString(string: "", attributes: entryNameAttributes)
        }
        
        let _fullText = NSMutableAttributedString(string: firstMeaningString, attributes: firstMeaningAttributes)
             
        
        if word != "" {
            _fullText.append(NSAttributedString(string: "\n\n" + word, attributes: entryNameAttributes))
        }
            
        if let _transcription = transcription {
            _fullText.append(NSAttributedString(string: " [" + _transcription + "]", attributes: transcriptionAttributes))
        }
            
        if let _partOfSpeech = partOfSpeech {
            _fullText.append(NSAttributedString(string: " " + _partOfSpeech, attributes: posAttributes))
        }
            
           
        for i in 0..<translateWords.count {
            if translateWords.count > 1 {
                _fullText.append(NSAttributedString(string: "\n\n \(i + 1)\t", attributes: counterAttributes))
            } else {
                _fullText.append(NSAttributedString(string: "\n\n\t", attributes: counterAttributes))
            }
                    
            _fullText.append(NSAttributedString(string: translateWords[i].word, attributes: meaningAttributes))
        }
            
        _fullText.addAttributes([NSAttributedString.Key.paragraphStyle: paragraphStyle], range: NSMakeRange(0, _fullText.string.count))
        
        return _fullText
    }
    
}
