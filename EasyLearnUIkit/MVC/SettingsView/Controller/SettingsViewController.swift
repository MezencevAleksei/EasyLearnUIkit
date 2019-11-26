//
//  SettingsViewController.swift
//  EasyLearn
//
//  Created by alex on 17.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var countOfLearningWords: UITextField!
    @IBOutlet weak var yandexApiKey: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupHideKeyboard()
        setupSettings()
        
    }

    func setupSettings(){
        if let textField = countOfLearningWords{
            if let number = SettingsModel.getSetting(setting: "NumberOfWordsToLearn", defaultValue: 10) {
                let result = number as! Int
                textField.text = "\(result)"
            }
        }
    }
        
           func setupHideKeyboard(){
               let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard as (UIInputViewController) -> () -> Void))
               tap.cancelsTouchesInView = false
               view.addGestureRecognizer(tap)
           }
           
           @objc func dismissKeyboard() {
              view.endEditing(true)
            }
    

    @IBAction func addYandexApiKey(_ sender: Any) {
        if let key = yandexApiKey.text {
            APIKey.setKey(key: key)
        }
    }
    
    @IBAction func DidEndEditCountOfLearningWords(_ sender: Any) {
        if let textField = countOfLearningWords{
            if let countStr = textField.text{
                if let countInt = Int(countStr){
                    SettingsModel.setSetting(setting: "NumberOfWordsToLearn", value: countInt)
                }
            }
        }
    }
    
    
    @IBAction func goToMakeYandexApiKey(_ sender: Any) {
        if let url = URL(string: "https://yandex.ru/dev/keys/get/?service=dict") {
            UIApplication.shared.open(url)
        }
    }
}
