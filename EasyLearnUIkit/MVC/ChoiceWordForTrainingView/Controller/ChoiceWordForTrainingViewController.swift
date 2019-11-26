//
//  ChoiceWordForTrainingViewController.swift
//  EasyLearn
//
//  Created by alex on 24.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import UIKit

class ChoiceWordForTrainingViewController: UIViewController {

    @IBOutlet var wordsTableView: UITableView!
    @IBOutlet weak var selectionChoiceSegment: UISegmentedControl!
    var words = [WordModel]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wordsTableView.delegate   = self
        self.wordsTableView.dataSource = self
        setupView()
        self.updateWordsForLearn()
    }
    
    @IBAction func changedSelection(_ sender: Any) {
        updateWordsForLearn()
    }
    
    func setupView(){
         wordsTableView.register(WordChoiseCell.nib, forCellReuseIdentifier: WordChoiseCell.reuseID)
    }
    
    func updateWordsForLearn(){
        if let segment = selectionChoiceSegment{
            //Режим авто заполнение
            if segment.selectedSegmentIndex == 0 {
                DispatchQueue.global().async {
                    var countWordsToLearn = 5
                    if let number = SettingsModel.getSetting(setting: "NumberOfWordsToLearn", defaultValue: 10) {
                        countWordsToLearn = number as! Int
                    }
                    DataProvider.getWordForLearn(count: countWordsToLearn){ _words in
                        DispatchQueue.main.async {
                            if let words = _words{
                                self.words = words
                                if self.words.count > 0 {
                                    self.wordsTableView.reloadData()
                                }
                            }
                        }
                        
                    }
                }
            //Режим ручного выбора
            }else {
                
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LearnWordsSegue" {
            let controller = (segue.destination as! LearnWordsViewController)
            controller.setLearningWords(words: words)
        }
    }
    
}

extension ChoiceWordForTrainingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WordChoiseCell.reuseID, for: indexPath) as? WordChoiseCell else {
                   fatalError("Bad cell")
               }
        
        let word = self.words[indexPath.row]
        cell.setup(word:word.word, translate: word.wordTranslateString())
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.words.count
    }

}


