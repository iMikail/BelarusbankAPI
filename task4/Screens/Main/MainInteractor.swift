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

class MainInteractor: MainBusinessLogic {

    var presenter: MainPresentationLogic?
    var service: MainService?

    private let locationManager = CLLocationManager()
    private let bankManager = BankManager()
    private var isFirstRequest = true

    func makeRequest(request: Main.Model.Request.RequestType) {
        if service == nil {
            service = MainService()
        }
        switch request {
            case .updateData:
                updateData()
            case .setDelegate(let delegate):
                setupDelegates(delegate: delegate)
            case .attemptLocationAccess:
                attemptLocationAccess()
            case .setupElementOnMap(types: let types):
                presenter?.presentData(response: .allBankElements(elements: bankManager.allBankElements, types: types))
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
                        self.presenter?.presentData(response: .alertError(type: .errorConnection(errors: errorElements)))
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

    private func setupDelegates(delegate: MainViewController) {
        locationManager.delegate = delegate
        bankManager.delegate = delegate
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
