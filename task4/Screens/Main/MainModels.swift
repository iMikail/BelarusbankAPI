//
//  MainModels.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import UIKit

enum Main {

    enum Model {
        struct Request {
            enum RequestType {
                case setDelegate(delegate: MainViewController)
                case updateData
                case attemptLocationAccess
                case setupElementOnMap(types: [BankElements])
            }
        }

        struct Response {
            enum ResponseType {
                case responseData(dataArray: [DataForElement])
                case alertError(type: Main.AlertType)
                case enabledInterface
                case allBankElements(elements: [ElementResponse], types: [BankElements])
            }
        }

        struct ViewModel {
            enum ViewModelData {
                case showAlert(alertType: Main.AlertType)
                case enabledInterface
                case setupElementOnMap(elements: [ElementResponse], types: [BankElements])
            }
        }
    }

    enum AlertType {
        case noInternet
        case noLocationAccess
        case errorConnection(errors: [ErrorForElement])
    }
}
