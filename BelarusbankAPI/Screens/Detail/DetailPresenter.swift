//
//  DetailPresenter.swift
//  BelarusbankAPI
//
//  Created by Misha Volkov on 20.01.23.
//

protocol DetailPresentationLogic {
    func presentData(response: Detail.Model.Response.ResponseType)
}

class DetailPresenter: DetailPresentationLogic {
    weak var viewController: DetailDisplayLogic?

    func presentData(response: Detail.Model.Response.ResponseType) {
        switch response {
        case .detailData(let detailData):
            viewController?.displayData(viewModel: .updateView(detailData: detailData))
        }
    }
}
