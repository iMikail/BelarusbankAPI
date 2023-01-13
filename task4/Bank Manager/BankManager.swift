//
//  BankManager.swift
//  task4
//
//  Created by Misha Volkov on 9.01.23.
//

import UIKit
import CoreLocation

protocol BankManagerDelegate: AnyObject {
    func atmsDidUpdate()
    func infoboxDidUpdate()
    func filialsDidUpdate()
    func bankElementsWillSorted()
    func bankElementsDidSorted()
}

final class BankManager: NSObject {
    // MARK: - Properties
    weak var delegate: BankManagerDelegate?
    internal var atms = ATMResponse()
    internal var infoboxes = InfoboxResponse()
    internal var filials = FilialResponse()
    internal var sortedBankElements = [[ElementResponse]]()

    // MARK: - Functions
    internal func fetchElement(_ type: BankElements, id: String) -> ElementDescription? {
        switch type {
        case .atm: return atms.first(where: { $0.id == id })
        case .infobox: return infoboxes.first(where: { $0.id == id })
        case .filial: return filials.first(where: { $0.id == id })
        }
    }

    internal func updateElements(_ element: BankElements, fromData data: Data, userLocation location: CLLocation) {
        switch element {
        case .atm: updateAtms(fromData: data)
        case .infobox: updateInfobox(fromData: data)
        case .filial: updateFillials(fromData: data)
        }

        delegate?.bankElementsWillSorted()
        DispatchQueue.global(qos: .userInitiated).async {
            self.sortedBankElements = self.sortByCities(self.sortForCurrentLocation(location))
            DispatchQueue.main.async {
                self.delegate?.bankElementsDidSorted()
            }
        }
    }

    private func updateAtms(fromData data: Data) {
        do {
            atms = try ATMResponse(data: data)
            delegate?.atmsDidUpdate()
            print("atms updated, \(atms.count)")//-
        } catch let error {
            print(error)
        }
    }

    private func updateInfobox(fromData data: Data) {
        do {
            infoboxes = try InfoboxResponse(data: data)
            delegate?.infoboxDidUpdate()
            print("infoboxes updated, \(infoboxes.count)")//-
        } catch let error {
            print(error)
        }
    }

    private func updateFillials(fromData data: Data) {
        do {
            filials = try FilialResponse(data: data)
            delegate?.filialsDidUpdate()
            print("filials updated, \(filials.count)")//-
        } catch let error {
            print(error)
        }
    }

    private func sortForCurrentLocation(_ currentLocation: CLLocation) -> [ElementResponse] {
        let allElements: [ElementResponse] = atms + infoboxes + filials
        var sortedElements = [ElementResponse]()

        sortedElements = allElements.sorted { (firstElement, secondElement) in
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
            let city = allElements[0].city

            for element in allElements where element.city == city {
                array.append(element)
            }
            allElements.removeAll { $0.city == city }
            sortedElements.append(array)
        }

        return sortedElements
    }
}
