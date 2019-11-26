//
//  Settings.swift
//  EasyLearn
//
//  Created by alex on 24.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation

class SettingsModel{
    
    static let sharedInstance: SettingsModel = SettingsModel()
    
    private init(){
        
        setSettingIfNotExist(setting:"Backup count", value: 1)
        setSettingIfNotExist(setting:"Use auto backup", value: true)
        
    }
    
    private func setSettingIfNotExist(setting: String, value: Any){
        if SettingsModel.getSetting(setting: setting, defaultValue: nil) == nil {
            SettingsModel.setSetting(setting: setting, value: value)
        }
    }
    
    static func removeSetting(setting: String){

            UserDefaults.standard.removeObject(forKey: setting)
        
    }
    
    static func getSetting(setting:String, defaultValue: Any?)->Any?{

        if let value = UserDefaults.standard.object(forKey: setting){
            return value
        }else{
            return defaultValue
        }

    }
    
    static func setSetting(setting:String, value: Any){
       
            UserDefaults.standard.set(value, forKey: setting)

    }
  
    private static func postChanged(valueName: String){
        
        NotificationCenter.default.post(name: Notification.Name("UpdateUserDefaults"), object: nil, userInfo: [valueName : "update"])
    }

}
