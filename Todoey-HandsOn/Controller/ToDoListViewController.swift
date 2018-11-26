//
//  ViewController.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 23/11/18.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
//    var itemArray = ["Cuki One", "Cuki Two", "Cuki Three", "Cuki Four"]
    var itemArray: [Item] = []
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.tableFooterView = UIView()
        
        addItemsToItemArray()
        
//        if let items = defaults.array(forKey: "ToDoListArray") as? [String] {
//            itemArray = items
//        }
    }
    
    private func addItemsToItemArray(){
        let newItem = Item(title: "Cuki One")
        newItem.isDone = true
        itemArray.append(newItem)
        let newItem2 = Item(title: "Cuki Two")
        itemArray.append(newItem2)
        let newItem3 = Item(title: "Cuki Three")
        itemArray.append(newItem3)
        let newItem4 = Item(title: "Cuki Four")
        itemArray.append(newItem4)
        
        for i in 0...100{
            let newItemItterate = Item(title: "Cuki-cuki \(i)")
            itemArray.append(newItemItterate)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        
        // Swift ternary operator
        // (Value) = (condition) ? (valueIfTrue) : (valueIfFalse)
        cell.accessoryType = item.isDone ? .checkmark : .none
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].isDone = !(itemArray[indexPath.row].isDone)
        print(itemArray[indexPath.row].title, itemArray[indexPath.row].isDone)
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add New Items
    @IBAction func handleAddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add new todoey item?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // What will happen once user clicks the Add Item button on UIAlert
            if textField.text != "" {
                self.itemArray.append(Item(title: textField.text!))
                
//                self.defaults.set(self.itemArray, forKey: "ToDoListArray")
                
                self.tableView.reloadData()
                
            } else {
                let alert = UIAlertController(title: "Empty item inputted", message: "Please enter a non-empty text item name", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay!", style: .cancel, handler: nil)
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Please enter your new item"
            textField = alertTextField
        }
        
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
}

