//
//  Item.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 01/12/18.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    @objc dynamic var dateCreated: Date?
    
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
