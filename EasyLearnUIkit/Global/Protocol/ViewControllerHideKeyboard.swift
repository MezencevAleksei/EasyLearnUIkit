//
//  ViewControllerHideKeyboard.swift
//  EasyLearn
//
//  Created by alex on 17.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

import Foundation
import UIKit

class ViewControllerHideKeyboard: ViewControllerLifecycleBehavior{

    func beforeDisappearing(_ viewController: UIViewController) {
         NotificationCenter.default.removeObserver(viewController)
    }
    
    
    func afterAppearing(_ viewController: UIViewController) {
        UIViewController.keyboardDismissTapGesture = nil
        
    }
    
}
