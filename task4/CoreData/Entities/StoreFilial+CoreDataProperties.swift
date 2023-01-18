//
//  StoreFilial+CoreDataProperties.swift
//  task4
//
//  Created by Misha Volkov on 18.01.23.
//
//

import Foundation
import CoreData

extension StoreFilial {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreFilial> {
        return NSFetchRequest<StoreFilial>(entityName: "StoreFilial")
    }

    @NSManaged public var data: Data?
}

extension StoreFilial: Identifiable {}
