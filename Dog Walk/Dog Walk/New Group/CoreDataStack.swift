//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by Neil Hiddink on 5/31/18.
//  Copyright © 2018 Neil Hiddink. All rights reserved.
//

import Foundation
import CoreData

// MARK: CoreDataStack

class CoreDataStack {
    
    // MARK: Properties
    
    private let modelName: String
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores {
            (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    // MARK: Initialization
    
    init(modelName: String) {
        self.modelName = modelName
    }
    
    // MARK: Convenience Methods
    
    func saveContext () {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
}
