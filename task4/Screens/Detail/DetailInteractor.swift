//
//  DetailInteractor.swift
//  task4
//
//  Created by Misha Volkov on 20.01.23.
//

import CoreLocation

protocol DetailBusinessLogic {
    func makeRequest(request: Detail.Model.Request.RequestType)
}

protocol DetailDataStore {
    var detailData: DetailViewModel? { get set }
}

class DetailInteractor: DetailBusinessLogic, DetailDataStore {
    var detailData: DetailViewModel?

    var presenter: DetailPresentationLogic?

    func makeRequest(request: Detail.Model.Request.RequestType) {
        switch request {
        case .updateView:
            guard let detailData = detailData else { return }
            presenter?.presentData(response: .detailData(detailData: detailData))
        }
    }
}
