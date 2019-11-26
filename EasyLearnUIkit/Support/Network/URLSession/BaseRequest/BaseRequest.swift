//
//  BaseRequest.swift
//  Otus_HW_13
//
//  Created by alex on 06/10/2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

struct BaseRequest {
    
    
    let session = URLSession.shared
    
    func downloadTask(url: String, complition: @escaping (_ json: Any, _ data: Data) -> Void) {
        
        guard let url = URL(string: url) else { return print("ERROR") }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil || data == nil {
                //print("Client error!")
                return
            }
            
            guard let res = response as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
               // print("Server error!")
                return
            }
            
            //let mi = res.mimeType
            guard let mime = res.mimeType, mime == "application/json" else {
                //print("Wrong MIME type! \(String(describing: mi))")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                complition(json, data!)
            } catch {
                //print("JSON error: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}


//200
//Операция выполнена успешно
//
//401
//Неправильный API-ключ
//
//402
//API-ключ заблокирован
//
//404
//Превышено суточное ограничение на объем переведенного текста
//
//413
//Превышен максимально допустимый размер текста
//
//422
//Текст не может быть переведен
//
//501
//Заданное направление перевода не поддерживается
