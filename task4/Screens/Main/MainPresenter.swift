//
//  MainPresenter.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import UIKit

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
        case .allBankElements(let elements):
            viewController?.displayData(viewModel: .updateAllBankElements(elements: elements))
        case .filteredBankElements(let elements):
            viewController?.displayData(viewModel: .updateFilteredElements(elements: elements))
        case .currentLocation(let location):
            viewController?.displayData(viewModel: .updateLocation(location: location))
        }
    }

}
