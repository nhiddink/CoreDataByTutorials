//
//  AppDelegate.swift
//  Dog Walk
//
//  Created by Neil Hiddink on 5/31/18.
//  Copyright © 2018 Neil Hiddink. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: Properties
    
    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack(modelName: "Dog Walk")
    
    // MARK: App Delegate Methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        guard let navigationController = window?.rootViewController as? UINavigationController,
              let viewController = navigationController.topViewController as? ViewController else { return true }

        viewController.managedContext = coreDataStack.managedContext
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataStack.saveContext()
    }
}

