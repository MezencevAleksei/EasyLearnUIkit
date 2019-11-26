//
//  NotificationService.swift
//  EasyLearn
//
//  Created by alex on 31.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

final public class NotificationService{
    
    static func createNotification(title: String, body: String, date: Date)-> String{
        
            // 1
            let content = UNMutableNotificationContent()
            content.title = title
            //content.subtitle = "from ioscreator.com"
            content.body = body
            
            // 2
            
            let imageName = "NotificationImage"
            if let imageURL = Bundle.main.url(forResource: imageName, withExtension: nil){
                    
                let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)

                content.attachments = [attachment]
            }
            // 3
            let timeInterval = Date().distance(to: date)
            let uid = UUID().uuidString
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
            let request = UNNotificationRequest(identifier: uid, content: content, trigger: trigger)
            
            // 4
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            return uid
        }
    
    
    
    
}
