//
//  Backup.swift
//  EasyLearn
//
//  Created by alex on 26.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

struct DataProvider{
    static func addNewWord(_ word: WordModel) -> Bool{
        let sql = SQLDB.sharedInstance
        return sql.addWord(word: word)
    }
    
    static func getWord(_ word: String) -> WordModel?{
        guard word != "" else {return nil}
        let sql = SQLDB.sharedInstance
        return sql.getWord(word: word)
    }
    
    static func getWord(_ words: [String]) -> [String : WordModel]?{
        guard words.count > 0 else {return nil}
        let sql = SQLDB.sharedInstance
        return sql.getWords(words: words)
    }
    
    static func getAllWords(sort: TypeOfSortWords) -> [String : WordModel]?{
        let sql = SQLDB.sharedInstance
        return sql.getAllAWords(sort:sort)
    }
    
    static func translateText(word: String,
                              complitionHandler: @escaping(_ word: String, _ wordModel: WordModel?)->()){
        
        Request().getTranslateFromURL(word: word, complitionHendler: complitionHandler)
    }
    
    static func translateWord(word: String,
                                 complitionHandler: @escaping(_ word: String, _ wordModel: WordModel?)->()){
           
           Request().lookupWordInDictionaryFromURL(word: word, complitionHendler: complitionHandler)
       }
    
    static func getWordForLearn(count: Int, complitionHandler: @escaping(_ wordModel: ([WordModel])?)->()){
    
        let sql = SQLDB.sharedInstance
        sql.getWordForLearn(count: count, complitionHandler: complitionHandler)
    }
}
    

