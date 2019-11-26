//
//  APIKey.swift
//  EasyLearn
//
//  Created by alex on 17.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation


class APIKey {
    enum Service{
        case translate
        case dictionary
    }
    static private let curentSerice: Service = .dictionary
    
    #if DEBUG
    static private let YandexTranslateKey: String = "trnsl.1.1.20191027T130940Z.3e3d8016a2d97ba4.b3c4fd72c1e8b155d0160a5bc5dc001e7e25da73"
    static private let YandexDictionaryKey: String = "dict.1.1.20191107T163258Z.8d2fd936d6eefeca.ae76822655b51ca83dbb5f843715e06b613784b8"
    #endif
    
    static func setKey(key: String){
        SettingsModel.setSetting(setting: "YandexAPIKey", value: key)
    }
    
    static func getKey()->String{
        return  APIKey.key(curentSerice)
    }
    
    static private func key(_ service: Service)-> String{
        
        var result = ""
        
        if let savedKey = SettingsModel.getSetting(setting: "YandexAPIKey", defaultValue: nil) {
            if savedKey is String {
                return savedKey as! String
            }
        }
        
        switch service {
        case .translate:
            result = self.YandexTranslateKey
        case .dictionary:
            result = YandexDictionaryKey
        }
        return result
    }
    
    
}
