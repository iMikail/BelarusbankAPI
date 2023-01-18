//
//  CoreDataManager.swift
//  task4
//
//  Created by Misha Volkov on 18.01.23.
//

import Foundation
import CoreData

final class CoreDataManager {
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "StoreElements")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()

    lazy var viewContext: NSManagedObjectContext = persistentContainer.viewContext

    func saveContext() {

        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }

    func deleteEntity<T: NSManagedObject>(_ entity: T.Type) {
        var requested = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entity))
        do {
            let fetched = try viewContext.fetch(requested)
            for object in fetched {
                if let storeEntity = object as? NSManagedObject {
                    viewContext.delete(storeEntity)
                    print("\(entity) - deleted")//-
                }
            }
        } catch {
            let nserror = error as NSError
            print(nserror.description)
        }
    }

    func saveDataForEntity<T: NSManagedObject & StoreElement>(_ entity: T.Type, data: Data) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: entity),
                                                                 in: viewContext) else {
            return
        }

        var storeEntity = T(entity: entityDescription, insertInto: viewContext)
        storeEntity.data = data
        print("save context \(entity)")
        saveContext()
    }

    func fetchStoreDataForEntity<T: NSManagedObject & StoreElement>(_ entity: T.Type) -> Data {
        var data = Data()
        do {
            let fetchData = NSFetchRequest<T>(entityName: String(describing: entity))
            let storeEntities = try viewContext.fetch(fetchData)
               if let storeData = storeEntities.first?.data {
                data = storeData
            }
        } catch let error {
            print(error)
        }

        return data
    }
}
