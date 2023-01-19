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
            case .responseData(dataArray: let dataArray):
                break
            case .allBankElements(let elements, let types):
                viewController?.displayData(viewModel: .setupElementOnMap(elements: elements, types: types))
        }
    }

}
