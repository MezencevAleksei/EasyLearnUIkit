//
//  ResponceYandexAPI.swift
//  EasyLearn
//
//  Created by alex on 09.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation


struct ResponseYandexDict: Decodable {
    let dictEntriesArray: [DictEntry]?
    
    private enum CodingKeys: String, CodingKey {
        case dictEntriesArray = "def"
    }
}

struct DictEntry: Decodable {
    let text: String?
    let partOfSpeech: String?
    let transcription: String?
    let translationsArray: [MainTranslation]?
    
    private enum CodingKeys: String, CodingKey {
        case text
        case partOfSpeech = "pos"
        case transcription = "ts"
        case translationsArray = "tr"
    }
}

struct MainTranslation: Decodable {
    let text: String?
    let partOfSpeech: String?
    let aspect: String?
    let gender: String?
    let synonymsArray: [Synonym]?
    let meaningsArray: [Meaning]?
    let examplesArray: [Example]?
    
    private enum CodingKeys: String, CodingKey {
        case text
        case partOfSpeech = "pos"
        case aspect = "asp"
        case gender = "gen"
        case synonymsArray = "syn"
        case meaningsArray = "mean"
        case examplesArray = "ex"
    }
}

struct Synonym: Decodable {
    let text: String?
    let partOfSpeech: String?
    let aspect: String?
    let gender: String?
    
    private enum CodingKeys: String, CodingKey {
        case text
        case partOfSpeech = "pos"
        case aspect = "asp"
        case gender = "gen"
    }
}

struct Meaning: Decodable {
    let text: String?
}

struct Example: Decodable {
    let text: String?
    let exampleTranslationsArray: [ExampleTranslation]?
    
    private enum CodingKeys: String, CodingKey {
        case text
        case exampleTranslationsArray = "tr"
    }
}

struct ExampleTranslation: Decodable {
    let text: String?
}

