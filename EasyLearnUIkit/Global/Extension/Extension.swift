//
//  Extension.swift
//  EasyLearn
//
//  Created by alex on 24.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation
import UIKit

extension Date{
    
    func textFromeDateWithFormat(format:String)->String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        let timeText = dateFormatter.string(from: self)
        return timeText
    }
}


extension Double {
    
    func date()->Date?{
        if self > 0 {
            return Date(timeIntervalSince1970: TimeInterval(self))
        }else{
            return nil
        }
    }
    func min(_ numb: Double)->Double{
        return self <= numb ? self : numb
    }
    
    func max(_ numb: Double)->Double{
        return self >= numb ? self : numb
    }
}

extension UIColor {
    static var veryDarkBlue = UIColor.rgb(red: 24, green: 34, blue: 44)
    static var darkBlue = UIColor.rgb(red: 34, green: 47, blue: 62)
    static var lightYellow = UIColor.rgb(red: 255, green: 238, blue: 163)
    static var brightYellow = UIColor.rgb(red: 255, green: 219, blue: 61)
    static var beige = UIColor.rgb(red: 205, green: 205, blue: 205)
    static var middleGray = UIColor.rgb(red: 143, green: 149, blue: 156)
    static var golden = UIColor.rgb(red: 255, green: 215, blue: 0)
    static var lowAqua = UIColor.rgb(red: 211, green: 218, blue: 222)
    static var greenSmoke = UIColor.rgb(red: 99, green: 121, blue: 133)
    static var blueSmoke = UIColor.rgb(red: 127, green: 147, blue: 158)
    static var elevenOclock = UIColor.rgb(red: 35, green: 49, blue: 64)
    static var greenButton = UIColor.rgb(red: 84, green: 217, blue: 109)
    static var redButton = UIColor.rgb(red: 252, green: 63, blue: 56)
    
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
}


extension UIViewController {
    static var keyboardDismissTapGesture: UIGestureRecognizer?
        
    // КЛАВИАТУРА ПОЯВИЛАСЬ - добавляем "распознаватель жестов"
     func keyboardWillShow(notification: NSNotification) {
            if UIViewController.keyboardDismissTapGesture == nil
            {
                UIViewController.keyboardDismissTapGesture = UITapGestureRecognizer(
                                              target: self,
                                              action: Selector(("dismissKeyboard:")))
                UIViewController.keyboardDismissTapGesture?.cancelsTouchesInView = false
                self.view.addGestureRecognizer(UIViewController.keyboardDismissTapGesture!)
            }
        }
        
    func dismissKeyboard(sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
        
    // КЛАВИАТУРА СКРЫЛАСЬ - убираем "распознаватель жестов"
     func keyboardWillHide(notification: NSNotification) {
            if UIViewController.keyboardDismissTapGesture != nil
            {
                self.view.removeGestureRecognizer(UIViewController.keyboardDismissTapGesture!)
                UIViewController.keyboardDismissTapGesture = nil
            }
        }
}


extension Date{
    func textFromeDate()->String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        let timeText = dateFormatter.string(from: self)
        return timeText
    }
}
