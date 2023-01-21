//
//  MainPresenter.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import UIKit
import CoreLocation

protocol MainPresentationLogic {
    func presentData(response: Main.Model.Response.ResponseType)
}

class MainPresenter: MainPresentationLogic {
    weak var viewController: MainDisplayLogic?

    func presentData(response: Main.Model.Response.ResponseType) {
        switch response {
        case .alertError(let alertType):
            viewController?.displayData(viewModel: .showAlert(alertType: alertType))
        case .enabledInterface:
            viewController?.displayData(viewModel: .enabledInterface)
        case .updatedAllData(let elements, let types, let location):
            viewController?.displayData(viewModel: .updateAllBankElements(elements: elements))
            updateAllElements(elements, forTypes: types, forLocation: location)
        case .sortedElements(let elements, let filteringTypes):
            let filteredElements = filteredElements(elements, forTypes: filteringTypes)
            viewController?.displayData(viewModel: .updateFilteredElements(elements: filteredElements))
        case .currentLocation(let location):
            viewController?.displayData(viewModel: .updateLocation(location: location))
        }
    }

    private func updateAllElements(_ elements: [ElementResponse],
                                   forTypes types: [BankElements],
                                   forLocation location: CLLocation) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }

            let sortedArray = self.sortedElements(elements, forLocation: location)
            let filteredArray = self.filteredElements(sortedArray, forTypes: types)

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }

                self.viewController?.displayData(viewModel: .updateSortedBankElements(elements: sortedArray))
                self.viewController?.displayData(viewModel: .updateFilteredElements(elements: filteredArray))
            }
        }
    }

    // MARK: Filtering/Sorting functions
    private func filteredElements(_ elements: [[ElementResponse]],
                                  forTypes types: [BankElements]) -> [[ElementResponse]] {
        return elements.map { elements in
            elements.filter { element in
                types.contains(element.elementType)
            }
        }
    }

    private func sortedElements(_ elements: [ElementResponse],
                                forLocation location: CLLocation) -> [[ElementResponse]] {
        return sortByCities(sortElements(elements, forLocation: location))
    }

    private func sortElements(_ elements: [ElementResponse], forLocation location: CLLocation) -> [ElementResponse] {
        var sortedElements = [ElementResponse]()

        sortedElements = elements.sorted { (firstElement, secondElement) in
            if let firstLatitude = Double(firstElement.latitude),
               let firstLongitude = Double(firstElement.longitude),
               let secondLatitude = Double(secondElement.latitude),
               let secondLongitude = Double(secondElement.longitude) {
                let firstLocation = CLLocation(latitude: firstLatitude, longitude: firstLongitude)
                let secondLocation = CLLocation(latitude: secondLatitude, longitude: secondLongitude)

                return firstLocation.distance(from: location) < secondLocation.distance(from: location)
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
