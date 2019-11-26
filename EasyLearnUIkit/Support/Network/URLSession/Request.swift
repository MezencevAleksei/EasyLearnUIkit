//
//  Request.swift
//  Otus_HW_13
//
//  Created by alex on 06/10/2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

public class Request {

    private let request = BaseRequest()
    private var translayteAPI_URL = TranslayteAPI_URL()
    private var dictionaryAPI_URL = DictionaryAPI_URL()
    
    func getTranslateFromURL(word: String, complitionHendler: @escaping(_ word: String, _ wordModel: WordModel?)->()) {
        let url = translayteAPI_URL.urlConfigList(word: word, languageFrom: nil, langugeTo: nil)
        self.request.downloadTask(url: url.absoluteString) {(json, _)  in
            let dJson = JSON(json)
            
            if let wordArray = dJson["text"].array {
                var array = [String]()
                for trWord in wordArray {
                    if let _word = trWord.string {
                        array.append(_word)
                    }
                }
                 
                let wordModel = WordModel(word: word, translateWords: array, langugeFrom: "en", LangugeTo: "ru", date: Date())

                complitionHendler(word,wordModel)
            }else{
                complitionHendler(word,nil)
            }
        }
    }
    
    func lookupWordInDictionaryFromURL(word: String, complitionHendler: @escaping(_ word: String, _ wordModel: WordModel?)->()) {
        let url = dictionaryAPI_URL.urlConfigList(word: word, languageFrom: nil, langugeTo: nil)
        self.request.downloadTask(url: url.absoluteString) {(json, data)  in
            
            do {
                let decodedResponse = try JSONDecoder().decode(ResponseYandexDict.self, from: data)
                
                if let entries = decodedResponse.dictEntriesArray, entries.isEmpty {
                    return
                }
                let word = WordModel(decodedResponse: decodedResponse, langugeFrom: "en", LangugeTo: "ru")
                complitionHendler(word.word,word)
 
            } catch let error {
                AlertManager.shared.showAlert(title: "Ошибка", message: "Во время перевода произошла ошибка: \(error)")
            }
    
        }
    }
}

