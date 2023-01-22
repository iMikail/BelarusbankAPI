//
//  MainInteractor.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import UIKit
import CoreLocation

protocol MainBusinessLogic {
    var filteredTypes: [BankElements] { get set }
    var sortedBankElements: [[ElementResponse]]? { get set }

    func makeRequest(request: Main.Model.Request.RequestType)
}

protocol MainDataStore {
    var detailData: DetailViewModel? { get set }
}

class MainInteractor: NSObject, MainBusinessLogic, MainDataStore {
    var presenter: MainPresentationLogic?
    var service: MainService?

    private let locationManager = CLLocationManager()
    private let bankManager = BankManager()

    var detailData: DetailViewModel?
    var filteredTypes = BankElements.allCases
    var sortedBankElements: [[ElementResponse]]?

    override init() {
        super.init()
        bankManager.delegate = self
        locationManager.delegate = self
    }

    func makeRequest(request: Main.Model.Request.RequestType) {
        switch request {
        case .updateData:
            updateData()
        case .attemptLocationAccess:
            attemptLocationAccess()
        case .updateFilteredTypes(let types):
            updateFilteredTypes(types)
        case.updateRouterDataStore(let type, let id):
            guard let element = bankManager.fetchElement(type, id: id),
                  let coordinate = locationManager.location?.coordinate else {
                return
            }
            detailData = DetailViewModel(userCoordinate: coordinate, element: element)
        }
    }

    private func updateData() {
        service?.updateData { [weak self] (connected, dataArray, errorElements) in
            guard let self = self else { return }

            self.presenter?.presentData(response: .enabledInterface)
            if let dataArray = dataArray {
                self.bankManager.updateElements(dataArray)
            }
            if connected {
                if let errorElements = errorElements {
                    self.presenter?.presentData(
                        response: .alertError(.errorConnection(errors: errorElements)))
                }
            } else {
                self.presenter?.presentData(response: .alertError(.noInternet))
            }
        }
    }

    private func updateFilteredTypes(_ types: [BankElements]) {
        filteredTypes = types
        if let sortedBankElements = sortedBankElements {
            presenter?.presentData(
                response: .filteringUpdated(allElements: bankManager.allBankElements,
                                            sortedElements: sortedBankElements,
                                            filteringTypes: filteredTypes))
        }
    }

    private func attemptLocationAccess() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
                presenter?.presentData(response: .alertError(.noLocationAccess))
        default:
            locationManager.requestLocation()
        }
    }
}

// MARK: BankManagerDelegate
extension MainInteractor: BankManagerDelegate {
    func bankElementsDidUpdated(_ elements: [ElementResponse]) {
        let location = locationManager.location ?? locationManager.defaultLocation
        presenter?.presentData(response: .updatedAllData(elements: elements,
                                                         types: filteredTypes,
                                                         location: location))
    }
}

// MARK: CLLocationManagerDelegate
extension MainInteractor: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
            if let location = manager.location {
                presenter?.presentData(response: .currentLocation(location))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            presenter?.presentData(response: .currentLocation(location))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
