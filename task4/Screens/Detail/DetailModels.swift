//
//  DetailModels.swift
//  task4
//
//  Created by Misha Volkov on 20.01.23.
//

import UIKit
import CoreLocation

protocol ElementDescription {
    var latitude: String { get }
    var longitude: String { get }
    var elementType: BankElements { get }

    func arrayDescriptions() -> [String]
}

enum Detail {

    enum Model {
        struct Request {
            enum RequestType {
                case updateView
            }
        }

        struct Response {
            enum ResponseType {
                case detailData(detailData: DetailViewModel)
            }
        }

        struct ViewModel {
            enum ViewModelData {
                case updateView(detailData: DetailViewModel)
            }
        }
    }
}

struct DetailViewModel {
    var userCoordinate: CLLocationCoordinate2D?
    var element: ElementDescription?
}
