//
//  CategoryViewController.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 29/11/2018.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {
    
    // MARK: - Attributes
    var categories: Results<Category>?
    
    // Realm Attributes
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategory()
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            let selectedCategory = categories?[indexPath.row] ?? Category()
            destinationVC.selectedCategory = selectedCategory
            destinationVC.title = selectedCategory.name
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let item = categories?[indexPath.row]{
                do{
                    try realm.write {
                        // Cascade delete
                        realm.delete(item.items)
                        realm.delete(item)
                    }
                } catch {
                    print("Error deleting category:", error.localizedDescription)
                }
            }
            tableView.reloadData()
        }
    }
    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories have been added!"
        return cell
    }
    
    // MARK: - Data Manipulation Methods
    func loadCategory(){
        categories = realm.objects(Category.self).sorted(byKeyPath: "name", ascending: true)
        
        tableView.reloadData()
    }
    
    func saveCategory(_ category: Category){
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error in saving data:",error.localizedDescription)
        }
    }
    
    // MARK: - IBActions
    @IBAction func handleAddButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alertController = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let addAction = UIAlertAction(title: "Add Category", style: .default) { (_) in
            if textField.text != ""{
                let category = Category()
                category.name = textField.text!
                
                self.saveCategory(category)
                self.tableView.reloadData()
            } else {
                let alert = UIAlertController(title: "Empty item inputted", message: "Please enter a non-empty text item name", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay!", style: .cancel, handler: nil)
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        alertController.addAction(addAction)
        alertController.addTextField { (alertTextField) in
            alertTextField.placeholder = "Type your new category here"
            textField = alertTextField
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
}
