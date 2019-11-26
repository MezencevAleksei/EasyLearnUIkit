//
//  MainModel.swift
//  EasyLearn
//
//  Created by alex on 31.10.2019.
//  Copyright © 2019 Mezencev Aleksei. All rights reserved.
//

import Foundation


public enum TypeOfSortWords: Int ,CaseIterable{
    case abc = 0
    case addTime = 1
    case repeatTime = 2
    
    func index()-> Int{
        var result: Int = 0
        switch self {
        case .abc:
            result = 0
        case .addTime:
            result = 1
        case .repeatTime:
            result = 2
        }
        return result
    }
}
