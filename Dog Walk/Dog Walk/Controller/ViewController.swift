//
//  ViewController.swift
//  Dog Walk
//
//  Created by Neil Hiddink on 5/31/18.
//  Copyright © 2018 Neil Hiddink. All rights reserved.
//

import UIKit
import CoreData

// MARK: ViewController: UIViewController

class ViewController: UIViewController {
    
    // MARK: - Properties
    
    var managedContext: NSManagedObjectContext!
    
    lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var currentDog: Dog?
    
    // MARK: IB Outlets
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let dogName = "Fido"
        let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
        dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName)
        
        do {
            let results = try managedContext.fetch(dogFetch)
            if results.count > 0 {
                currentDog = results.first
            } else { // not found
                currentDog = Dog(context: managedContext)
                currentDog?.name = dogName
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        
    }
}

// MARK: IB Actions

extension ViewController {
    @IBAction func add(_ sender: UIBarButtonItem) {

        let walk = Walk(context: managedContext)
        walk.date = NSDate()

        if let dog = currentDog,
            let walks = dog.walks?.mutableCopy()
                as? NSMutableOrderedSet {
            walks.add(walk)
            dog.walks = walks
        }
        // Alternatively...
        //currentDog?.addToWalks(walk)

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Save error: \(error), description: \(error.userInfo)")
        }
        
        // Reload table view
        tableView.reloadData()
    }
}

// MARK: UITableViewDataSource Methods
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let walks = currentDog?.walks else { return 1 }
        return walks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let walk = currentDog?.walks?[indexPath.row] as? Walk,
              let walkDate = walk.date as Date? else { return cell }
        
        cell.textLabel?.text = dateFormatter.string(from: walkDate)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of Walks"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk,
              editingStyle == .delete else { return }
        
        managedContext.delete(walkToRemove)
        
        do {
            try managedContext.save()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } catch let error as NSError {
            print("Saving error: \(error), description: \(error.userInfo)")
        }
    }
}
