//
//  BankManager.swift
//  task4
//
//  Created by Misha Volkov on 9.01.23.
//

import UIKit
import CoreLocation

protocol BankManagerDelegate: AnyObject {
    func bankElementsDidUpdated(_ elements: [ElementResponse])
}

final class BankManager: NSObject {
    // MARK: - Properties
    private let networkService = NetworkService()
    private let coreDataManager = CoreDataManager()

    weak var delegate: BankManagerDelegate?

    var atms = ATMResponse()
    var infoboxes = InfoboxResponse()
    var filials = FilialResponse()

    var allBankElements: [ElementResponse] { return atms + infoboxes + filials }

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
                    completion: ((Bool, [ErrorForElement]?) -> Void)? = nil) {//->worker
        guard NetworkMonitor.shared.isConnected else {
            loadStoreData(forTypes: types)
            completion?(false, nil)
            return
        }

        networkService.getDataForTypes(types) { [weak self] (dataArray, errors) in
            guard let self = self  else { return }

            self.saveData(dataArray)
            self.updateElements(dataArray)

            if errors.isEmpty {
                completion?(true, nil)
            } else {
                errors.forEach { (_, type) in
                    self.loadStoreData(forTypes: [type])
                }
                completion?(true, errors)
            }
        }
    }

    private func loadStoreData(forTypes types: [BankElements]) {//->worker
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

        updateElements(dataArray)
    }

    private func saveData(_ dataArray: [DataForElement]) {//->worker
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

    private func updateElements(_ elements: [DataForElement]) {
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
        delegate?.bankElementsDidUpdated(allBankElements)
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
}
