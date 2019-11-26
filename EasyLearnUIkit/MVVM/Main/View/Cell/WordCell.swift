//
//  WordsForRepeatCell.swift
//  EasyLearnUIKit
//
//  Created by alex on 03.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import UIKit

class WordCell: UITableViewCell {

        static let reuseID: String = String(describing: WordCell.self)
        static let nib: UINib = UINib(nibName: String(describing: WordCell.self), bundle: nil)
        
        private var wordModel: WordModel?
        @IBOutlet var wordLabel: UILabel!
        @IBOutlet var wordTranscriptionLabel: UILabel!
        @IBOutlet var wordTranslateLabel: UILabel!
        @IBOutlet var addTime: UILabel!
    
        
        override func awakeFromNib() {
            super.awakeFromNib()
            
        }
        
        func setup(word: WordModel) {
            self.wordModel = word
            self.wordLabel.text = word.word
            self.wordTranslateLabel.text = word.wordTranslateString()
            if let tr = word.transcription{
                self.wordTranscriptionLabel.text = "[" + tr + "]"
            }
            if let addTime = word.dateAdd{
                self.addTime.text = addTime.textFromeDate()
            }
        }
    
        
}
