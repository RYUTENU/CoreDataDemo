//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by 劉 天宇 on 2020/11/30.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Reference to managed object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var items: [Person]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Get items from Core Data
        fetchPeople()
    }
    
    func relationshipDemo() {
        
        // Create a family
        let family = Family(context: context)
        family.name = "Abc Family"
        
        // Create a person
        let person = Person(context: context)
        person.name = "Maggie"
        
        // Add person to family
        family.addToPeople(person)
        
        // Save context
        do {
            try context.save()
        }
        catch {
            
        }
    }
    
    func fetchPeople() {
        
        // Fetch the data from Core Data to display in the tableview
        do {
            let request = Person.fetchRequest() as NSFetchRequest<Person>
            
            /*
            // Set the filtering on the request
            let pred = NSPredicate(format: "name CONTAINS %@", "Ted")
            request.predicate = pred
            
            // Set the sorting on the request
            let sort = NSSortDescriptor(key: "name", ascending: true)
            request.sortDescriptors = [sort]
            */
            
            items = try context.fetch(request)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        catch {
            
        }
    }
    
    @IBAction func actionAdd(_ sender: Any) {
        
        // Create alert
        let alert = UIAlertController(title: "Add Person", message: "What is their name?", preferredStyle: .alert)
        alert.addTextField()
        
        // Configure button handler
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            
            // Get the textfield for the alert
            guard let textfield = alert.textFields?[0] else { return }
            
            // Create a person object
            let newPerson = Person(context: self.context)
            newPerson.name = textfield.text
            newPerson.age = 20
            newPerson.gender = "Male"
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            // Re-fetch the data
            self.fetchPeople()
        }
        // Add button
        alert.addAction(submitButton)
        
        // Show alert
        present(alert, animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return the number of people
        return items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PersonCell", for: indexPath)
        
        // Get person from array and set the label
        guard let person = items?[indexPath.row] else { return UITableViewCell(style: .default, reuseIdentifier: "error") }
        
        cell.textLabel?.text = person.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Selected Person
        guard let person = items?[indexPath.row] else { return }
        
        // Create alert
        let alert = UIAlertController(title: "Edit Person", message: "Edit name:", preferredStyle: .alert)
        alert.addTextField()
        
        guard let textfield = alert.textFields?[0] else { return }
        textfield.text = person.name
        
        // Configure button handler
        let saveButton = UIAlertAction(title: "Save", style: .default) { (action) in
            
            // Get the textfield for the alert
            guard let textfield = alert.textFields?[0] else { return }
            
            // Edit name property of person object
            person.name = textfield.text
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            // Re-fetch the data
            self.fetchPeople()
        }
        // Add button
        alert.addAction(saveButton)
        
        // Show alert
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            
            // Which person to remove
            guard let personToRemove = self.items?[indexPath.row] else { return }
            
            // Remove the person
            self.context.delete(personToRemove)
            
            // Save the data
            do {
                try self.context.save()
            }
            catch {
                
            }
            // Re-fetch the data
            self.fetchPeople()
        }
        // Return swipe actions
        return UISwipeActionsConfiguration(actions: [action])
    }
}
