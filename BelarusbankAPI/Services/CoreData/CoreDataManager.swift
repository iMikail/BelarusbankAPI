//
//  CoreDataManager.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 18.01.23.
//

import CoreData

protocol StoreElement {
    var data: Data? { get set }
}

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

    func fetchStoreData(forTypes types: [BankElements]) -> [DataForElement] {
        var dataArray = [DataForElement]()

        types.forEach { type in
            var data: Data
            switch type {
            case .atm:
                data = fetchStoreDataForEntity(StoreATM.self)
            case .infobox:
                data = fetchStoreDataForEntity(StoreInfobox.self)
            case .filial:
                data = fetchStoreDataForEntity(StoreFilial.self)
            }
            dataArray.append((data, type))
        }

        return dataArray
    }

    func updateData(_ dataArray: [DataForElement]) {
        for (data, type) in dataArray {
            switch type {
            case .atm:
                deleteEntity(StoreATM.self)
                saveDataForEntity(StoreATM.self, data: data)
            case .infobox:
                deleteEntity(StoreInfobox.self)
                saveDataForEntity(StoreInfobox.self, data: data)
            case .filial:
                deleteEntity(StoreFilial.self)
                saveDataForEntity(StoreFilial.self, data: data)
            }
        }
    }

    private func deleteEntity<T: NSManagedObject>(_ entity: T.Type) {
        let requested = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: entity))
        do {
            let fetched = try viewContext.fetch(requested)
            for object in fetched {
                if let storeEntity = object as? NSManagedObject {
                    viewContext.delete(storeEntity)
                }
            }
        } catch {
            let nserror = error as NSError
            print(nserror.description)
        }
    }

    private func saveDataForEntity<T: NSManagedObject & StoreElement>(_ entity: T.Type, data: Data) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: String(describing: entity),
                                                                 in: viewContext) else {
            return
        }

        var storeEntity = T(entity: entityDescription, insertInto: viewContext)
        storeEntity.data = data
        saveContext()
    }

    private func fetchStoreDataForEntity<T: NSManagedObject & StoreElement>(_ entity: T.Type) -> Data {
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
