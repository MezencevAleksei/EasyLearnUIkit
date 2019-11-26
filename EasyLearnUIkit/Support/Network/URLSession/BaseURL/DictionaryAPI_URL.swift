//
//  BaseUrl.swift
//  Otus_HW_13
//
//  Created by alex on 06/10/2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

struct DictionaryAPI_URL {
    
    /* https://dictionary.yandex.net/api/v1/dicservice.json/lookup
     ?key=API-ключ&
     lang=en-ru&
     text=time
     */
    
    
    var urlComponents = URLComponents()
    let scheme = "https"
    let host   = "dictionary.yandex.net"
    let path   = "/api/v1/dicservice.json/lookup"
    
    let queryItemKey = URLQueryItem(name: "key", value: APIKey.getKey())
    let queryItemLang = URLQueryItem(name: "lang", value: "en-ru")
    let queryItemUI = URLQueryItem(name: "ui", value: "ru")
    
    mutating func urlConfigList(word:String, languageFrom: String?, langugeTo: String?) -> URL {
        urlComponents.scheme = self.scheme
        urlComponents.host   = self.host
        urlComponents.path   = self.path
        
        let queryItemText = URLQueryItem(name: "text", value: word)
        urlComponents.queryItems = [queryItemKey,
                                    queryItemText,
                                    queryItemLang,
                                    queryItemUI]
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        return url
    }
}

