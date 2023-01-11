//
//  ATMAnnotation.swift
//  task4
//
//  Created by Misha Volkov on 29.12.22.
//

import MapKit

final class ElementAnnotation: NSObject, MKAnnotation, ElementResponse {
    var title: String?
    let id: String
    let latitude: String
    let longitude: String
    let installPlace: String
    let currency: String
    let workTime: String
    let cashIn: String
    let elementType: BankElements
    let phoneInfo: String

    var coordinate: CLLocationCoordinate2D {
        if let latitude = Double(latitude), let longitude = Double(longitude) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            return CLLocationCoordinate2D()
        }
    }

    init(fromElement element: ElementResponse) {
        title = element.elementType.elementName
        id = element.id
        latitude = element.latitude
        longitude = element.longitude
        installPlace = element.installPlace
        currency = element.currency
        workTime = element.workTime
        cashIn = element.cashIn
        elementType = element.elementType
        phoneInfo = element.phoneInfo
    }
}
