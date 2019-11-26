//
//  WordChoiseCell.swift
//  EasyLearn
//
//  Created by alex on 24.11.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import UIKit

class WordChoiseCell: UITableViewCell {

    static let reuseID: String = String(describing: WordChoiseCell.self)
    
    static let nib: UINib = UINib(nibName: String(describing: WordChoiseCell.self), bundle: nil)
    
    @IBOutlet weak var wordLabel:     UILabel!
    @IBOutlet weak var translateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(word: String, translate: String){
        if let _wordLabel = self.wordLabel, let _translateLabel = self.translateLabel{
            _wordLabel.text      = word
            _translateLabel.text = translate
        }
    }
}
