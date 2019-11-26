//
//  BaseUrl.swift
//  Otus_HW_13
//
//  Created by alex on 06/10/2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

struct TranslayteAPI_URL {
    
    /* https://newsapi.org/v2/top-headlines?' +
    'country=us&' +
    'apiKey=ffcf3615bbe24a18805af3af69eb0d5f'
    
     https://translate.yandex.net/api/v1.5/tr.json/translate
     
     */
    
    
    var urlComponents = URLComponents()
    let scheme = "https"
    let host   = "translate.yandex.net"
    let path   = "/api/v1.5/tr.json/translate"
    
//    [key=<API-ключ>]
//    & [text=<переводимый текст>]
//    & [lang=<направление перевода>]
//    & [format=<формат текста>]
//    & [options=<опции перевода>]
//    & [callback=<имя callback-функции>]
    

    let queryItemKey = URLQueryItem(name: "key", value: APIKey.getKey())
    let queryItemLang = URLQueryItem(name: "lang", value: "en-ru")
    let queryItemFormat = URLQueryItem(name: "format", value: "plain")
    
    mutating func urlConfigList(word:String, languageFrom: String?, langugeTo: String?) -> URL {
        urlComponents.scheme = self.scheme
        urlComponents.host   = self.host
        urlComponents.path   = self.path
        
        let queryItemText = URLQueryItem(name: "text", value: word)
        urlComponents.queryItems = [queryItemKey,queryItemText,queryItemLang,queryItemFormat]
        
        guard let url = urlComponents.url else { fatalError("Could not create URL from components") }
        return url
    }
}

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
