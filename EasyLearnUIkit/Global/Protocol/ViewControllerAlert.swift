//
//  ViewControllerDataCaching.swift
//  Otus_HW_12
//
//  Created by alex on 13.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation
import UIKit

class ViewControllerAlert: ViewControllerLifecycleBehavior{

    func beforeDisappearing(_ viewController: UIViewController) {
        AlertManager.shared.currentViewController = nil
    }
    
    func beforeAppearing(_ viewController: UIViewController) {
        
        AlertManager.shared.currentViewController = viewController
        
    }
    
}
