//
//  Data.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 01/12/18.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import Foundation
import RealmSwift

class Data: Object {
    
    // Dynamic enables Realm to detect change and update the database
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 0
}
