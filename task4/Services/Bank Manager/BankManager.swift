//
//  BankManager.swift
//  task4
//
//  Created by Misha Volkov on 9.01.23.
//

import UIKit
import CoreLocation

protocol BankManagerDelegate: AnyObject {
    func bankElementsDidUpdated()
    func bankElementsDidFiltered()
}

final class BankManager: NSObject {
    // MARK: - Properties
    private let networkService = NetworkService()
    private let coreDataManager = CoreDataManager()
    private var filteredTypes = BankElements.allCases
    weak var delegate: BankManagerDelegate?

    var atms = ATMResponse()
    var infoboxes = InfoboxResponse()
    var filials = FilialResponse()

    var allBankElements: [ElementResponse] { return atms + infoboxes + filials }
    private var sortedBankElements = [[ElementResponse]]()
    var filteredBankElements = [[ElementResponse]]()

    // MARK: - Functions
    func fetchElement(_ type: BankElements, id: String) -> ElementDescription? {
        switch type {
        case .atm:
            return atms.first(where: { $0.itemId == id })
        case .infobox:
            return infoboxes.first(where: { $0.itemId == id })
        case .filial:
            return filials.first(where: { $0.itemId == id })
        }
    }

    // MARK: Updating functions
    func updateData(forTypes types: [BankElements] = BankElements.allCases,
                    location: CLLocation,
                    completion: ((Bool, [ErrorForElement]?) -> Void)? = nil) {
        guard NetworkMonitor.shared.isConnected else {
            loadStoreDataForTypes(types, userLocation: location)
            completion?(false, nil)
            return
        }

        networkService.getDataForTypes(types) { [weak self] (dataArray, errors) in
            guard let self = self  else { return }

            self.saveData(dataArray)
            self.updateElements(dataArray, userLocation: location)

            if errors.isEmpty {
                completion?(true, nil)
            } else {
                errors.forEach { (_, type) in
                    self.loadStoreDataForTypes([type], userLocation: location)
                }
                completion?(true, errors)
            }
        }
    }

    func updateFilteredTypes(_ types: [BankElements]) {
        filteredTypes = types
        filteredElementsForTypes()
    }

    private func loadStoreDataForTypes(_ types: [BankElements], userLocation: CLLocation) {
        var dataArray = [DataForElement]()

        types.forEach { type in
            var data: Data
            switch type {
            case .atm:
                data = coreDataManager.fetchStoreDataForEntity(StoreATM.self)
            case .infobox:
                data = coreDataManager.fetchStoreDataForEntity(StoreInfobox.self)
            case .filial:
                data = coreDataManager.fetchStoreDataForEntity(StoreFilial.self)
            }
            dataArray.append((data, type))
        }

        updateElements(dataArray, userLocation: userLocation)
    }

    private func saveData(_ dataArray: [DataForElement]) {
        for (data, type) in dataArray {
            switch type {
            case .atm:
                coreDataManager.deleteEntity(StoreATM.self)
                coreDataManager.saveDataForEntity(StoreATM.self, data: data)
            case .infobox:
                coreDataManager.deleteEntity(StoreInfobox.self)
                coreDataManager.saveDataForEntity(StoreInfobox.self, data: data)
            case .filial:
                coreDataManager.deleteEntity(StoreFilial.self)
                coreDataManager.saveDataForEntity(StoreFilial.self, data: data)
            }
        }
    }

    private func updateElements(_ elements: [DataForElement], userLocation location: CLLocation) {
        elements.forEach { (data, type) in
            switch type {
            case .atm:
                updateAtms(fromData: data)
            case .infobox:
                updateInfobox(fromData: data)
            case .filial:
                updateFillials(fromData: data)
            }
        }
        delegate?.bankElementsDidUpdated()

        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }

            let sortedArray = self.sortByCities(self.sortForCurrentLocation(location))

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.sortedBankElements = sortedArray
                self.filteredElementsForTypes()
            }
        }
    }

    private func updateAtms(fromData data: Data) {
        do {
            atms = try ATMResponse(data: data)
        } catch let error {
            print(error)
        }
    }

    private func updateInfobox(fromData data: Data) {
        do {
            infoboxes = try InfoboxResponse(data: data)
        } catch let error {
            print(error)
        }
    }

    private func updateFillials(fromData data: Data) {
        do {
            filials = try FilialResponse(data: data)
        } catch let error {
            print(error)
        }
    }

    // MARK: Filtering/Sorting functions
    //->Presenter
    private func filteredElementsForTypes() {
        filteredBankElements = sortedBankElements.map { elements in
            elements.filter { element in
                filteredTypes.contains(element.elementType)
            }
        }
        delegate?.bankElementsDidFiltered()
    }

    private func sortForCurrentLocation(_ currentLocation: CLLocation) -> [ElementResponse] {
        var sortedElements = [ElementResponse]()

        sortedElements = allBankElements.sorted { (firstElement, secondElement) in
            if let firstLatitude = Double(firstElement.latitude),
               let firstLongitude = Double(firstElement.longitude),
               let secondLatitude = Double(secondElement.latitude),
               let secondLongitude = Double(secondElement.longitude) {
                let firstLocation = CLLocation(latitude: firstLatitude, longitude: firstLongitude)
                let secondLocation = CLLocation(latitude: secondLatitude, longitude: secondLongitude)

                return firstLocation.distance(from: currentLocation) < secondLocation.distance(from: currentLocation)
            } else {
                return false
            }
        }

        return sortedElements
    }

    private func sortByCities(_ elements: [ElementResponse]) -> [[ElementResponse]] {
        var allElements: [ElementResponse] = elements
        var sortedElements = [[ElementResponse]]()

        while !allElements.isEmpty {
            var array = [ElementResponse]()
            let city = allElements[0].itemCity

            for element in allElements where element.itemCity == city {
                array.append(element)
            }
            allElements.removeAll { $0.itemCity == city }
            sortedElements.append(array)
        }

        return sortedElements
    }
}
