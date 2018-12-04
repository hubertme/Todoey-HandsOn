//
//  ViewController.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 23/11/18.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import UIKit
import RealmSwift

class ToDoListViewController: UITableViewController {
    
    var todoItems: Results<Item>?
    var selectedCategory: Category?{
        didSet{
            loadItems()
        }
    }
    var dateFormatString = "dd MMM yyyy, HH:mm:ss"
    
    // MARK: Persistent container instances
    let defaults = UserDefaults.standard
    let realm = try! Realm()
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        searchBar.delegate = self
        
        // Fetch server time
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.detailTextLabel?.text = ""
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormatString
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT+")
            if let dateCreatedForCell = item.dateCreated{
                cell.detailTextLabel?.text = dateFormatter.string(from: dateCreatedForCell)
            }
            cell.detailTextLabel?.textColor = .gray
            
            // Swift ternary operator
            // (Value) = (condition) ? (valueIfTrue) : (valueIfFalse)
            cell.accessoryType = item.isDone ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items inputted!"
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.isDone = !(item.isDone)
                }
            } catch {
                print("Error updating checkmark:", error.localizedDescription)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let item = todoItems?[indexPath.row] {
                do{
                    try realm.write {
                        realm.delete(item)
                    }
                }
                catch {
                    print("Error deleting data:", error.localizedDescription)
                }
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - Add New Items
    @IBAction func handleAddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add new todoey item?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            // What will happen once user clicks the Add Item button on UIAlert
            if textField.text != "" {
                
                if let currentCategory = self.selectedCategory{
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            
                            self.fetchServerTimeReturn({ (date) in
                                DispatchQueue.main.async {
                                    do {
                                        try self.realm.write {
                                            newItem.dateCreated = date
                                        }
                                        self.tableView.reloadData()
                                    } catch {
                                        print("Failed to load server date with error:", error.localizedDescription)
                                    }
                                }
                            })
                            
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error adding item:", error.localizedDescription)
                    }
                }
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
    
    // MARK: - Private functions
    private func loadItems(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }
    
    // Fetch time from server (online)
    private func fetchServerTimeReturn(_ completion: @escaping (_ resDate: Date) -> Void){
        guard let url = URL(string: "https://www.google.com") else {return}
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error in fetching server time:", error.localizedDescription)
            }
            
            if let response = response {
                let httpResponse = response as? HTTPURLResponse
                if let dateString = httpResponse!.allHeaderFields["Date"] as? String{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
                    guard let serverDateAndTime = dateFormatter.date(from: dateString) else {return}
                    completion(serverDateAndTime)
                }
            }
        }
        task.resume()
    }
}

// MARK: - 
extension ToDoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        todoItems = todoItems?.filter(predicate).sorted(byKeyPath: "dateCreated", ascending: false)
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text! == ""{
            self.loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

