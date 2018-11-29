//
//  CategoryViewController.swift
//  Todoey-HandsOn
//
//  Created by Hubert Wang on 29/11/2018.
//  Copyright © 2018 Hubert Wang. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    // MARK: - Attributes
    var categoriesArray: [Category] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadItemsWithRequest()
    }
    
    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoriesArray[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            context.delete(categoriesArray[indexPath.row])
            categoriesArray.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.saveItems()
        }
    }
    
    // MARK: - TableView DataSource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categoriesArray[indexPath.row].name
        return cell
    }
    
    // MARK: - Data Manipulation Methods
    func loadItemsWithRequest(_ request: NSFetchRequest<Category> = Category.fetchRequest()){
        do {
            categoriesArray = try context.fetch(request)
            tableView.reloadData()
        } catch {
            print("Error in fetching data:",error.localizedDescription)
        }
    }
    
    func saveItems(){
        do {
            try context.save()
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
                let category = Category(context: self.context)
                category.name = textField.text!
                
                self.categoriesArray.append(category)
                self.saveItems()
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
