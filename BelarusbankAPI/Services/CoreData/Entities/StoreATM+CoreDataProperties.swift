//
//  StoreATM+CoreDataProperties.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 18.01.23.
//
//

import Foundation
import CoreData

extension StoreATM {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreATM> {
        return NSFetchRequest<StoreATM>(entityName: "StoreATM")
    }

    @NSManaged public var data: Data?
}

extension StoreATM: Identifiable {}
