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

    }

}
