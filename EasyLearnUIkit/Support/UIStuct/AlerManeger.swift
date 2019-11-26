//
//  AlerManeger.swift
//  EasyLearn
//
//  Created by alex on 26.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import UIKit
import SwiftUI

class AlertManager{
    
    var title: String?
    var message: String?
    var showComplition: (()->())?
    var swiftUI: Bool = false
    var currentViewController: UIViewController?
    private var isActive = false
    
    public static let shared = AlertManager()
    
    private init(){}
    
    func setShowComplition(_ complition: @escaping ()->() ){
        self.showComplition = complition
    }
    
    func showAlert(){
        if let _showComplition = showComplition {
            _showComplition()
        }
    }
    
    func showAlert(title: String?, message: String?, complition: ((_ result:UIAlertAction) -> Void)? = nil, withTimer: Bool = false) {
        guard !isActive else {return}
        
        if swiftUI{
            self.title = title
            self.message = message
            if let _showComplition = showComplition {
                _showComplition()
            }
        }else {
            isActive = true
            var mTitle = ""
            var mMessage = ""
            if let _title = title{
                mTitle = _title
            }
             
            if let _message = message{
                mMessage = _message
            }

            alertWindow(title: mTitle, message: mMessage, complition: complition, withTimer: withTimer)
        }
    }
    
    
    
    private func alertWindow(title: String, message: String,  complition: ((_ result:UIAlertAction) -> Void)? = nil, withTimer: Bool = false) {
        DispatchQueue.main.async(execute: {
    
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                if let _complition = complition{
                    _complition(action)
                }
            })
            alert.addAction(defaultAction)
            if let _currentViewController = self.currentViewController{
                _currentViewController.present(alert, animated: true){self.isActive = false}
                if withTimer {
                    let when = DispatchTime.now() + 1
                    DispatchQueue.main.asyncAfter(deadline: when){
                        alert.dismiss(animated: true, completion: nil)
                        self.isActive = false
                    }
                }
            }
        })
    }
    
}

