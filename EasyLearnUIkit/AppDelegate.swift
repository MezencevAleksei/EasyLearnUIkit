//
//  AppDelegate.swift
//  EasyLearnUIkit
//
//  Created by alex on 05.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let sqldb: SQLDB = SQLDB.sharedInstance


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        DispatchQueue.global(qos: .userInteractive).async{
                  self.sqldb.openBase()
              }
               
        if let _launchOptions = launchOptions {
                  if let notificationOption = _launchOptions[UIApplication.LaunchOptionsKey.remoteNotification] {
                      SettingsModel.setSetting(setting: "notificationOption", value: notificationOption)
                  }
              }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        sqldb.closeBase()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        sqldb.closeBase()
    }

}

