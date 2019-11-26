//
//  LearnWordsViewController.swift
//  EasyLearnUIKit
//
//  Created by alex on 03.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import UIKit

class LearnWordsViewController: UIViewController {

    private var viewModel = LearnWordViewModel()
    @IBOutlet weak var jobDescription: UILabel!
    @IBOutlet weak var wordForStudy: UILabel!
    
    @IBOutlet weak var trainingArea: UIView!
    private var answerButtonArray = [(index:Int,button: UIButton)]()
    private var viewOfRightAnswer: UITextView?
    
    
    @IBAction func stopTraning(_ sender: Any) {
        endTraining()
    }
    
    func endTraining(){
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showOrHideAnswer(_ sender: Any) {
        DispatchQueue.main.async {
            if let view = self.viewOfRightAnswer{
                view.removeFromSuperview()
                self.viewOfRightAnswer = nil
            }else {
                guard let _trainingArea = self.trainingArea else {return}
                let view = UITextView()
                view.frame = CGRect(x: 0, y: 0, width: _trainingArea.frame.width, height: _trainingArea.frame.height)
                view.backgroundColor = UIColor(red: 87/255, green: 132/255, blue: 150/255, alpha: 1)
                view.attributedText = self.viewModel.curentTraining?.currentWord?.wordModel.getTranslateText()
                view.layer.cornerRadius = 5
                view.clipsToBounds = true
                self.viewOfRightAnswer = view
                _trainingArea.addSubview(view)
            }
        }
    }
    
    
    @IBAction func speakTheWord(_ sender: Any) {
        viewModel.speakCurrentWord()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBiding()
        startTraining()
    }
    
    private func startTraining(){
        viewModel.startTraining()
    }
    
    func setLearningWords(words: [WordModel]){
        self.viewModel.wordsForLearn = words
    }
    
    func setupBiding(){
        
        viewModel.addBindingUpdateCurrentTraining(){ training  in
            DispatchQueue.main.async {
                //Очистим старые кнопки
                if self.answerButtonArray.count > 0 {
                    for button in self.answerButtonArray {
                        button.button.removeFromSuperview()
                    }
                    self.answerButtonArray.removeAll()
                }
 
                self.wordForStudy.text = training.mainWord
                self.jobDescription.text = training.getJobDescription()
                //для тренировки по буквам кнопки распологаем горизонтально
                let vstack = training.typeOfTraining == .translationByLetters ? false : true
                //Добавим кнопки с ответами
                for answer in training.answerWords{
                    if let frame = self.calculateFrameForAnswerButton(number: answer.number, count:training.answerWords.count, verticalStack: vstack){
                        self.addButton(frame: frame, title: answer.word, number: answer.number)
                    }
                }
            }
         
            
            self.viewModel.addBindingErrorAnswer(){ index in
                DispatchQueue.main.async {
                    for _button in self.answerButtonArray{
                        if _button.index == index {
                            _button.button.backgroundColor = UIColor.red
                        }
                    }
                }
            }
            
            self.viewModel.addBindingRightAnswer(){ index in
                DispatchQueue.main.async {
                    for _button in self.answerButtonArray{
                        if _button.index == index {
                            _button.button.backgroundColor = UIColor.green
                        }
                    }
                }
            }
            
            self.viewModel.addBindingEndTraining(){
                DispatchQueue.main.async {
                    self.endTraining()
                }
            }
        }
        
        
    }
    
    
    //Расчитаем размеры и положение кнопки относительно trainingArea по порядковому номеру,
    //number = 1...n
    func calculateFrameForAnswerButton(number: Int, count: Int, verticalStack: Bool)-> CGRect?{
        guard let mainView = self.trainingArea else {return nil}
            
        let mainFrame = mainView.frame
        let countCGF = CGFloat(count)
        let numbCGF  = CGFloat(number)
        
        var resultFrame: CGRect
        
        //Вертикальные кнопки (слова в кнопках)
        if verticalStack {
            let widthButton = round(0.7 * mainFrame.width)
            let x = round((mainFrame.width - widthButton) / 2 )
            let offsetHight = (mainFrame.height * 0.5) / (countCGF + 1)
            let hightButton = round((mainFrame.height - (offsetHight * (countCGF + 1))) / countCGF)
            let y = (hightButton * numbCGF) - hightButton + (offsetHight * numbCGF)
            resultFrame = CGRect(x: x, y: y, width: widthButton, height: hightButton)
        //Горизонтальные кнопки (буквы в кнопках)
        }else {
            let offsetWidth = round((mainFrame.width * 0.3) / (countCGF + 1))
            let widthButton = round((mainFrame.width - (offsetWidth * (countCGF + 1))) / countCGF)
            let hightButton = widthButton
            let x = (widthButton * numbCGF) - widthButton + (offsetWidth * numbCGF)
            
            let y =  offsetWidth
            resultFrame = CGRect(x: x, y: y, width: widthButton, height: hightButton)
        }
        return resultFrame
    }
    
    
    
    private func addButton(frame: CGRect,title: String, number: Int){
        guard title != "" && number > 0 && number < 14 else {return}
        
        if let _trainingArea = self.trainingArea{
            let button = UIButton()
            button.frame = frame
            button.backgroundColor = UIColor.gray
            button.setTitle(title, for: .normal)
            button.layer.cornerRadius = 5
            button.clipsToBounds = true
            
            let selector = self.getSelector(numb:number)
            button.addTarget(self, action: selector, for: .touchUpInside)
            _trainingArea.addSubview(button)
            
            answerButtonArray.append((index: number, button: button))
        }
    }
    
    private func getSelector(numb: Int)->Selector{
        var selector: Selector = Selector("action")
        switch numb {
        case 1:
            selector = #selector(action1)
        case 2:
            selector = #selector(action2)
        case 3:
            selector = #selector(action3)
        case 4:
            selector = #selector(action4)
        case 5:
            selector = #selector(action5)
        case 6:
            selector = #selector(action6)
        case 7:
            selector = #selector(action7)
        case 8:
            selector = #selector(action8)
        case 9:
            selector = #selector(action9)
        case 10:
            selector = #selector(action10)
        case 11:
            selector = #selector(action11)
        case 12:
            selector = #selector(action12)
        case 13:
            selector = #selector(action13)
        default:
            selector = #selector(action14)
        }
        return selector
    }
    
    @objc func action1(sender: UIButton!){
        viewModel.pressedButton(1)
    }
    
    @objc func action2(sender: UIButton!){
        viewModel.pressedButton(2)
    }
    
    @objc func action3(sender: UIButton!){
        viewModel.pressedButton(3)
    }
    
    @objc func action4(sender: UIButton!){
        viewModel.pressedButton(4)
    }
    
    @objc func action5(sender: UIButton!){
         viewModel.pressedButton(5)
    }
    
    @objc func action6(sender: UIButton!){
        viewModel.pressedButton(6)
    }
    
    @objc func action7(sender: UIButton!){
         viewModel.pressedButton(7)
    }
    
    @objc func action8(sender: UIButton!){
         viewModel.pressedButton(8)
    }
    
    @objc func action9(sender: UIButton!){
        viewModel.pressedButton(9)
    }
    @objc func action10(sender: UIButton!){
        viewModel.pressedButton(10)
    }
    @objc func action11(sender: UIButton!){
        viewModel.pressedButton(11)
    }
    @objc func action12(sender: UIButton!){
        viewModel.pressedButton(12)
    }
    @objc func action13(sender: UIButton!){
        viewModel.pressedButton(13)
    }
    @objc func action14(sender: UIButton!){
        viewModel.pressedButton(14)
    }
}
