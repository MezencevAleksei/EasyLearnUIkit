//
//  LearnWordViewModel.swift
//  EasyLearn
//
//  Created by alex on 02.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation




final class LearnWordViewModel{
    

    private var repeatStatistic = [(wordCount: Int, trainingType: TrainingType, susseccfulRepeat: Bool, timeRepeat: Date)]()
    private var countWordsToLearn: Int = {  var result: Int = 0
                                            if let number = SettingsModel.getSetting(setting: "NumberOfWordsToLearn", defaultValue: 10) {
                                               result = number as! Int
                                            }
                                            return result
                                          }()
    private var observers = [String :()->()]()
    var curentTraining: Training?
    var bindinderUpdateCurrentTraining: ((_ training: TrainingWord)->())?
    var bindinderErrorAnswer: ((_ index: Int)->())?
    var bindinderRightAnswer: ((_ index: Int)->())?
    var bindinderEndTraining:  (()->())?
    var wordsForLearn: [WordModel]?
    
    
    init() {
        addObservers()
    }
    
    private func addObservers(){
       //Добавим обсервер для свойства countWordsToLearn
        self.observers["NumberOfWordsToLearn"] = {
                                                    if let number = SettingsModel.getSetting(setting: "NumberOfWordsToLearn", defaultValue: 10) {
                                                        self.countWordsToLearn = number as! Int
                                                    }
                                                 }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNotification(notification:)), name: Notification.Name("UpdateUserDefaults"), object: nil)
       
    }
    
     @objc func receiveNotification(notification: Notification) {
        if let userInfo =  notification.userInfo{
            for object in observers{
                if let _ =  userInfo[object.key] {
                    object.value()
                }
            }
        }
     }
    
    func addBindingUpdateCurrentTraining(_ binder: @escaping (_ training: TrainingWord)->()){
        self.bindinderUpdateCurrentTraining = binder
    }
    
    func addBindingErrorAnswer(_ binder: @escaping (_ index: Int)->()){
        self.bindinderErrorAnswer = binder
    }
    
    func addBindingEndTraining(_ binder: @escaping ()->()){
        self.bindinderEndTraining = binder
    }
    
    func addBindingRightAnswer(_ binder: @escaping (_ index: Int)->()){
        self.bindinderRightAnswer = binder
    }
    
    
    func startTraining(){
        setupCurentTraining()
        if let binder = self.bindinderUpdateCurrentTraining , let tr = curentTraining{
            _ = tr.start()
            if let cTrainingWord = tr.currentWord{
                binder(cTrainingWord)
            }
        }
    }
    
    func setupCurentTraining(){
        if let words = self.wordsForLearn{
            self.curentTraining = Training(words: words)
        }
    }
    
    func pressedButton(_ numb: Int){
        
        if let cTraining = self.curentTraining{
            if let cWordTraining = cTraining.currentWord{
                
                    if cTraining.typeOfTraining != .translationByLetters{
                        if cWordTraining.checkRightAnswer(number: numb){
                            if let bindinderRightAnswer = self.bindinderRightAnswer{
                                bindinderRightAnswer(numb)
                            }
                            
                            if let nextWordTraining = cTraining.next(){
                                //Задержка перед следующим словом
                                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5){
                                    if let binder = self.bindinderUpdateCurrentTraining{
                                        binder(nextWordTraining)
                                    }
                                }
                            }else {
                                //если мы здесь значит все упражнения закончились
                                if let endBinder = self.bindinderEndTraining{
                                    self.wordsForLearn?.removeAll()
                                    endBinder()
                                }
                            }
                        }else {
                            if let binderErrorAnswer = self.bindinderErrorAnswer{
                                binderErrorAnswer(numb)
                            }
                        }
                    }else{
                        let simbol = cWordTraining.getAnswerByIndex(numb)
                        var isEnd = false
                        if cTraining.addLettersToWord(simbol: simbol, isEnd: &isEnd) {
                            if let bindinderRightAnswer = self.bindinderRightAnswer{
                                bindinderRightAnswer(numb)
                            }
                            if isEnd {
                                if let nextWordTraining = cTraining.next(){
                                    //Задержка перед следующим словом
                                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5){
                                        if let binder = self.bindinderUpdateCurrentTraining{
                                            binder(nextWordTraining)
                                        }
                                    }
                                }else {
                                    //если мы здесь значит все упражнения закончились
                                    if let endBinder = self.bindinderEndTraining{
                                        self.wordsForLearn?.removeAll()
                                        endBinder()
                                    }
                                }
                            }
                        }else{
                            if let binderErrorAnswer = self.bindinderErrorAnswer{
                                binderErrorAnswer(numb)
                            }
                        }
                    }
                }
           }
        
    }
    
    
    func speakCurrentWord(){
        if let tr = curentTraining{
            if let currentWord = tr.currentWord{
                VoiceProvider.sayWord(currentWord.mainWord)
            }
        }
    }
    
}








