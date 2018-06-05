//
//  Walk+CoreDataProperties.swift
//  Dog Walk
//
//  Created by Neil Hiddink on 5/31/18.
//  Copyright © 2018 Neil Hiddink. All rights reserved.
//
//

import Foundation
import CoreData


extension Walk {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Walk> {
        return NSFetchRequest<Walk>(entityName: "Walk")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var dog: Dog?

}
