//
//  Category.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 01/12/18.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name: String = ""
    
    let items = List<Item>()
}
