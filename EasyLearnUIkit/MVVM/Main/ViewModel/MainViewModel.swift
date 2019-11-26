//
//  MainViewEnvironmentObjact.swift
//  EasyLearn
//
//  Created by alex on 26.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation
import Combine
import UserNotifications


final class MainViewModel: ObservableObject {
    
    private var inputWord: String?
    private var wordsFromeDict = [WordModel]()
    var curentInputWord: WordModel?
    var typeOfSortWords: TypeOfSortWords {
        willSet{
            if newValue != typeOfSortWords{
                DispatchQueue.global().async {
                    SettingsModel.setSetting(setting: "typeOfSortWords", value: newValue.index())
                }
            }
        }
        didSet{
            updateWordsArray()
        }
    }
    private var binderUpdateWords: (()->())?
    private var binderCleanTranslatedWord: (()->())?
    private var binderUpdateTranslatedWord:((_ success:Bool)->())?
    private var binderChangeSort:((_ index:Int)->())?
    
 
    init() {
        let indexOfSort = SettingsModel.getSetting(setting: "typeOfSortWords", defaultValue: 0) as! Int
        self.typeOfSortWords =  TypeOfSortWords.init(rawValue: indexOfSort)!
        
        DispatchQueue.global().async {
            self.updateWordsArray()
        }
    }
    
    private func updateWordsArray(){
        if let wordsArray = DataProvider.getAllWords(sort: typeOfSortWords) {
            wordsFromeDict.removeAll()
            for word in wordsArray {
                wordsFromeDict.append(word.value)
            }
            if let binder = self.binderUpdateWords {
                binder()
            }
        }
    }
    
    
    //MARK: СВЯЗЫВАНИЕ с view
    func bindUpdateWords(_ binderUpdateWords: @escaping ()->()){
        self.binderUpdateWords = binderUpdateWords
    }
    
    func bindUpdateTranslatedWord(_ binderUpdateTranslatedWord: @escaping (_ success:Bool)->()){
        self.binderUpdateTranslatedWord = binderUpdateTranslatedWord
    }
    
    func bindCleanTranslatedWord(_ binderCleanTranslatedWord: @escaping ()->()){
        self.binderCleanTranslatedWord = binderCleanTranslatedWord
    }
    
    func bindChangeSort(_ binderChangeSort: @escaping (_ index:Int)->()){
        self.binderChangeSort = binderChangeSort
    }
    
    
    
    
    //MARK: ПОВТОРЕНИЕ
    func getWord(at index: Int)->WordModel?{
        guard wordsFromeDict.count > 0 else {return nil}
        let result = wordsFromeDict[index]
        return result
    }
    
    func getCountWords()-> Int{
        return wordsFromeDict.count

    }
    
    
    
    //MARK: ПЕРЕВОД И ДОБАВЛЕНИЕ НОВОГО СЛОВА В БАЗУ
    func translateWord(word: String){
        self.inputWord = word
        if let binder = self.binderUpdateTranslatedWord{
            if word != ""{
                inputWord = word
                DataProvider.translateWord(word: word) { (wordForTranslate, _translatedWord) in
                    if let _inputWord = self.inputWord{
                        if _inputWord == wordForTranslate {
                            self.curentInputWord = _translatedWord
                            binder(true)
                            return
                        }
                    }
                    self.curentInputWord = nil
                    if let binderClean = self.binderCleanTranslatedWord{
                        if let _inputWord = self.inputWord{
                            if _inputWord == wordForTranslate {
                                binderClean()
                            }
                        }
                    }
                    binder(false)
                }
            }
        }
    }


    func cleanCurrentWord(){
        self.curentInputWord = nil
        self.inputWord = nil
        if let binder = self.binderCleanTranslatedWord{
            binder()
        }
    }
    
    func addWord(completionHandler: @escaping(_ result:Bool)->()){
        var result = false
        if let curentWord = curentInputWord{
            result = DataProvider.addNewWord(curentWord)
            if result {
                if let binder = self.binderUpdateWords{
                    binder()
                }
                wordsFromeDict.append(curentWord)
                _ = NotificationService.createNotification(title: "Пора вспомнить слово", body: {curentWord.word + " - " + curentWord.translateWords[0].word}(), date: Date() + 300)
            }
        }
        completionHandler(result)
    }
    
    func requestedPermissionForNotification(){
        //Попросим разрешение на отправку сообщений пользователю, если еще не просили
        let _permissionForNotification = SettingsModel.getSetting(setting: "permission for notification", defaultValue: false)
        guard let permissionForNotification = _permissionForNotification else {return}
        if !(permissionForNotification as! Bool) {
            DispatchQueue.main.async {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) {
                    (granted, error) in
                    if granted {
                        SettingsModel.setSetting(setting: "permission for notification", value: true)
                    } else {
                        AlertManager.shared.showAlert(title: "Внимание!", message: "Для более эффективного изучения слов неоходимо повторение через определенные временные интервалы, для этого мы используем уведомления.")
                    }
                }
            }
        }
    }
    
    
    func sayWord() {
        
        if let wordText = self.inputWord{
            VoiceProvider.sayWord(wordText)
        }
    }
}





