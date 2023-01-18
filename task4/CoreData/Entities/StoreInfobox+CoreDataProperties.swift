//
//  StoreInfobox+CoreDataProperties.swift
//  task4
//
//  Created by Misha Volkov on 18.01.23.
//
//

import Foundation
import CoreData

extension StoreInfobox {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreInfobox> {
        return NSFetchRequest<StoreInfobox>(entityName: "StoreInfobox")
    }

    @NSManaged public var data: Data?
}

extension StoreInfobox: Identifiable {}
