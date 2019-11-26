//
//  MainViewController.swift
//  EasyLearnUIKit
//
//  Created by alex on 03.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {

    let viewModel: MainViewModel = MainViewModel()
    private var newWordInputSubscriber:Any?
    
    @IBOutlet var wordsTableView: UITableView!
    var translatedWordIndicator: UIActivityIndicatorView?
    @IBOutlet weak var newWordInput: UITextField!
    @IBOutlet weak var typeOfSortSegment: UISegmentedControl!
    @IBOutlet weak var translatedWordTextField: UITextView!
    private var lastRequestTime: Date?
    
    
    @IBAction func typeOfSortChanged(_ sender: Any) {
        self.viewModel.typeOfSortWords = TypeOfSortWords.init(rawValue: self.typeOfSortSegment.selectedSegmentIndex)!
    }
    
    
    @IBAction func addNewWord(_ sender: Any) {
        self.viewModel.addWord(){
            result in
            if result {
                //Здесь будет анимация
            }
        }
    }
    
    @IBAction func newWordInputChanged(_ sender: Any) {
        guard let text = self.newWordInput.text else {return}
        self.startTranslatedWordIndicator()
        lastRequestTime = Date()
        DispatchQueue.global(qos: .userInitiated).async {
            self.viewModel.translateWord(word: text.lowercased())
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10){ [weak self] in
            guard let `self` = self else {return}
            if let lastRequestTime = self.lastRequestTime, let indicator = self.translatedWordIndicator{
                if Date() > lastRequestTime.addingTimeInterval(9) && !indicator.isHidden {
                    self.stopTranslatedWordIndicator()
                }
            }
        }
    }
    
    
    
    @IBAction func sayWord(_ sender: Any) {
        self.viewModel.sayWord()
    }

 
    override func viewDidLoad() {
        super.viewDidLoad()
        addBehaviors(behaviors: [ViewControllerAlert(),ViewControllerHideKeyboard()])
        
        self.wordsTableView.delegate = self
        self.wordsTableView.dataSource = self
        
        setupBinder()
        setupView()
        setupHideKeyboard()
    }

    func setupHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard as (UIInputViewController) -> () -> Void))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
       view.endEditing(true)
     }
    
    func setupBinder(){
        self.viewModel.bindUpdateTranslatedWord(){ success in
            DispatchQueue.main.async {
                let inputWord = self.newWordInput.text?.lowercased()
                if success && inputWord == self.viewModel.curentInputWord?.word {
                    self.translatedWordTextField.attributedText = self.viewModel.curentInputWord?.getTranslateText()
                    self.stopTranslatedWordIndicator()
                }else {
                    
                }
            }
        }
        
        self.viewModel.bindCleanTranslatedWord(){
            DispatchQueue.main.async {
                self.translatedWordTextField.text = ""
                self.newWordInput.text = ""
            }
        }
        
        self.viewModel.bindChangeSort(){ index in
            DispatchQueue.main.async {
                self.typeOfSortSegment.selectedSegmentIndex = index
            }
        }
        
        self.viewModel.bindUpdateWords(){
            DispatchQueue.main.async {
                self.wordsTableView.reloadData()
            }
        }
    }
    
    func setupView(){
        typeOfSortSegment.selectedSegmentIndex = 0
        addActivityIndicator()
        wordsTableView.register(WordCell.nib, forCellReuseIdentifier: WordCell.reuseID)
    }
    
    func addActivityIndicator(){
        let frame = self.newWordInput.frame
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        let x = frame.maxX - frame.height/2
        let y = frame.minY + frame.height/2
        indicator.center = CGPoint(x: x, y: y)

        indicator.hidesWhenStopped = false
        indicator.stopAnimating()
        indicator.isHidden = true
        self.translatedWordIndicator = indicator
        self.newWordInput.addSubview(self.translatedWordIndicator!)
    }
    
    func stopTranslatedWordIndicator() {
         if let indicator = self.translatedWordIndicator{
             indicator.isHidden = true
             indicator.stopAnimating()
         }
     }
         
    func startTranslatedWordIndicator() {
        if let indicator = self.translatedWordIndicator{
            indicator.isHidden = false
            indicator.startAnimating()
        }
    }
     
}







extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WordCell.reuseID, for: indexPath) as? WordCell else {
                   fatalError("Bad cell")
               }
        if let word = self.viewModel.getWord(at: indexPath.row) {
            cell.setup(word:word)
        }
       
        return cell
    }
    
// Return the number of rows for the table.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.viewModel.getCountWords()
    }

   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

        if let currentCell = tableView.cellForRow(at: indexPath) as? WordCell, let _word = viewModel.getWord(at: indexPath.row){
            currentCell.setup(word: _word)
        }
    }
}
