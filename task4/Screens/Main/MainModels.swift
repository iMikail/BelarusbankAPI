//
//  MainModels.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import CoreLocation

protocol ElementResponse {
    var itemId: String { get }
    var itemCity: String { get }
    var latitude: String { get }
    var longitude: String { get }
    var itemInstallPlace: String { get }
    var itemWorkTime: String { get }
    var elementType: BankElements { get }
}

protocol TerminalElementResponse: ElementResponse {
    var itemCurrency: String { get }
    var itemCashIn: String { get }
}

protocol FilialElementResponse: ElementResponse {
    var itemPhoneInfo: String { get }
}

enum Main {

    enum Model {
        struct Request {
            enum RequestType {
                case updateData
                case attemptLocationAccess
                case updateFilteredTypes(_ types: [BankElements])
                case updateRouterDataStore(type: BankElements, id: String)
            }
        }

        struct Response {
            enum ResponseType {
                case alertError(_ type: Main.AlertType)
                case enabledInterface
                case updatedAllData(elements: [ElementResponse],
                                    types: [BankElements],
                                    location: CLLocation)
                case filteringUpdated(allElements: [ElementResponse],
                                      sortedElements: [[ElementResponse]],
                                      filteringTypes: [BankElements])
                case currentLocation(_ location: CLLocation)
            }
        }

        struct ViewModel {
            enum ViewModelData {
                case showAlert(_ alertType: Main.AlertType)
                case enabledInterface
                case updateAnnotations(_ annotations: [ElementAnnotation],
                                       forTypes: [BankElements])
                case updateSortedBankElements(_ elements: [[ElementResponse]])
                case updateFilteredElements(_ elements: [[ElementResponse]])
                case updateLocation(_ location: CLLocation)
            }
        }
    }

    enum AlertType {
        case noInternet
        case noLocationAccess
        case errorConnection(errors: [ErrorForElement])
    }
}
