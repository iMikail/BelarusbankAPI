//
//  MainRouter.swift
//  task4
//
//  Created by Misha Volkov on 19.01.23.
//

import UIKit

protocol MainRoutingLogic {
    func navigateToDetail(_ type: BankElements, id: String)
}

protocol MainDataPassing {
    var dataStore: MainDataStore? { get set }
}

class MainRouter: NSObject, MainRoutingLogic, MainDataPassing {
    weak var viewController: MainViewController?

    var dataStore: MainDataStore?

    // MARK: Routing
    func navigateToDetail(_ type: BankElements, id: String) {
        viewController?.interactor?.makeRequest(request: .updateRouterDataStore(type: type, id: id))
        let detailVC = DetailViewController()
        if let mainStore = dataStore, var detailStore = detailVC.router?.dataStore {
            passDataToDetail(source: mainStore, destination: &detailStore)
        }
        viewController?.navigationController?.pushViewController(detailVC, animated: true)
    }

    private func passDataToDetail(source: MainDataStore, destination: inout DetailDataStore) {
        destination.detailData = source.detailData
    }
}

// MARK: ElementAnnotationViewDelegate
extension MainRouter: ElementAnnotationViewDelegate {
    func fetchMoreInfoForElement(_ type: BankElements, id: String) {
        navigateToDetail(type, id: id)
    }
}
