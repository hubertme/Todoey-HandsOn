//
//  ViewController.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 23/11/18.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UITableViewController {
    var itemArray: [Item] = []
    
    // MARK: Persistent container instances
    let defaults = UserDefaults.standard
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadItems()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
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
        
        itemArray[indexPath.row].setValue(!(itemArray[indexPath.row].isDone), forKey: "isDone")
        self.saveItems()
        
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
                
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.isDone = false
                
                self.itemArray.append(newItem)
                self.saveItems()
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
    
    // MARK: - Stuffs about property list
    private func saveItems(){
        do{
           try context.save()
        } catch {
            print("Error saving context:",error.localizedDescription)
        }
    }
    
    private func loadItems(){
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data:",error.localizedDescription)
        }
    }
}

