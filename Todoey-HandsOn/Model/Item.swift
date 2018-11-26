//
//  Item.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 26/11/18.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import Foundation

class Item{
    var title: String = ""
    var isDone: Bool = false
    
    init(title: String) {
        self.title = title
    }
}
