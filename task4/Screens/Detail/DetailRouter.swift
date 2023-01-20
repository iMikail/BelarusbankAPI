//
//  DetailRouter.swift
//  task4
//
//  Created by Misha Volkov on 20.01.23.
//

import UIKit

protocol DetailRoutingLogic {

}

protocol DetailDataPassing {
    var dataStore: DetailDataStore? { get set }
}

class DetailRouter: NSObject, DetailRoutingLogic, DetailDataPassing {
    weak var viewController: DetailViewController?

    var dataStore: DetailDataStore?

    // MARK: Routing

}
