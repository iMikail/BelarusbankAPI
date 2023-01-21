//
//  MainModels.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import UIKit
import CoreLocation

enum Main {

    enum Model {
        struct Request {
            enum RequestType {
                case updateData
                case attemptLocationAccess
                case updateFilteredElements(types: [BankElements])
                case updateRouterDataStore(type: BankElements, id: String)
            }
        }

        struct Response {
            enum ResponseType {
                case alertError(type: Main.AlertType)
                case enabledInterface
                case updatedAllData(elements: [ElementResponse], types: [BankElements], location: CLLocation)
                case sortedElements(elements: [[ElementResponse]], filteringTypes: [BankElements])
                case currentLocation(location: CLLocation)
            }
        }

        struct ViewModel {
            enum ViewModelData {
                case showAlert(alertType: Main.AlertType)
                case enabledInterface
                case updateAllBankElements(elements: [ElementResponse])
                case updateSortedBankElements(elements: [[ElementResponse]])
                case updateFilteredElements(elements: [[ElementResponse]])
                case updateLocation(location: CLLocation)
            }
        }
    }

    enum AlertType {
        case noInternet
        case noLocationAccess
        case errorConnection(errors: [ErrorForElement])
    }
}
