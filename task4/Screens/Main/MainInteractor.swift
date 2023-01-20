//
//  MainInteractor.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import UIKit
import CoreLocation

protocol MainBusinessLogic {
    func makeRequest(request: Main.Model.Request.RequestType)
}

protocol MainDataStore {
    var detailData: DetailViewModel? { get set }
}

class MainInteractor: NSObject, MainBusinessLogic, MainDataStore {
    var detailData: DetailViewModel?

    var presenter: MainPresentationLogic?
    var service: MainService?

    private let locationManager = CLLocationManager()
    private let bankManager = BankManager()
    private var isFirstRequest = true

    override init() {
        super.init()
        bankManager.delegate = self
        locationManager.delegate = self
    }

    func makeRequest(request: Main.Model.Request.RequestType) {
        if service == nil {
            service = MainService()
        }
        switch request {
        case .updateData:
            updateData()
        case .attemptLocationAccess:
            attemptLocationAccess()
        case .updateElementsOnMap(let types):
            presenter?.presentData(response: .allBankElements(elements: bankManager.allBankElements))
        case .updateFilteredElements(let types):
            bankManager.updateFilteredTypes(types)
        case.updateRouterDataStore(let type, let id):
            guard let element = bankManager.fetchElement(type, id: id),
                  let coordinate = locationManager.location?.coordinate else {
                return
            }
            detailData = DetailViewModel(userCoordinate: coordinate, element: element)
        }
    }

    private func updateData() {
        let location = locationManager.location ?? locationManager.defaultLocation
        if isFirstRequest {
            bankManager.updateData(location: location) { [weak self] (connected, errorElements) in
                guard let self = self else { return }
                self.presenter?.presentData(response: .enabledInterface)
                self.isFirstRequest = false

                if connected {
                    if let errorElements = errorElements {
                        self.presenter?.presentData(
                            response: .alertError(type: .errorConnection(errors: errorElements)))
                    }
                } else {
                    self.presenter?.presentData(response: .alertError(type: .noInternet))
                }
            }
        } else {
            bankManager.updateData(forTypes: [.atm], location: location) { [weak self] (connected, _) in
                self?.presenter?.presentData(response: .enabledInterface)
                if !connected {
                    self?.presenter?.presentData(response: .alertError(type: .noInternet))
                }
            }
            bankManager.updateData(forTypes: [.infobox], location: location)
            bankManager.updateData(forTypes: [.filial], location: location)
        }
    }

    private func attemptLocationAccess() {
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            presenter?.presentData(response: .alertError(type: .noLocationAccess))
        default:
            locationManager.requestLocation()
        }
    }
}

// MARK: BankManagerDelegate
extension MainInteractor: BankManagerDelegate {
    func bankElementsDidFiltered() {
        presenter?.presentData(response: .filteredBankElements(elements: bankManager.filteredBankElements))
    }

    func bankElementsDidUpdated() {
        presenter?.presentData(response: .allBankElements(elements: bankManager.allBankElements))
    }
}

// MARK: CLLocationManagerDelegate
extension MainInteractor: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestLocation()
            if let location = manager.location {
                presenter?.presentData(response: .currentLocation(location: location))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            presenter?.presentData(response: .currentLocation(location: location))
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
