//
//  ATMAnnotation.swift
//  task4
//
//  Created by Misha Volkov on 29.12.22.
//

import MapKit

protocol ElementResponse {
    var itemId: String { get }
    var itemCity: String { get }
    var latitude: String { get }
    var longitude: String { get }
    var itemInstallPlace: String { get }
    var itemWorkTime: String { get }
    var elementType: BankElements { get }
    var itemCurrency: String { get }
    var itemCashIn: String { get }
    var itemPhoneInfo: String { get }
}

final class ElementAnnotation: NSObject, MKAnnotation, ElementResponse {
    let itemId: String
    let itemCity: String
    let latitude: String
    let longitude: String
    let itemInstallPlace: String
    let itemCurrency: String
    let itemWorkTime: String
    let itemCashIn: String
    let elementType: BankElements
    let itemPhoneInfo: String

    var coordinate: CLLocationCoordinate2D {
        if let latitude = Double(latitude), let longitude = Double(longitude) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            return CLLocationCoordinate2D()
        }
    }

    init(fromElement element: ElementResponse) {
        itemId = element.itemId
        itemCity = element.itemCity
        latitude = element.latitude
        longitude = element.longitude
        itemInstallPlace = element.itemInstallPlace
        itemCurrency = element.itemCurrency
        itemWorkTime = element.itemWorkTime
        itemCashIn = element.itemCashIn
        elementType = element.elementType
        itemPhoneInfo = element.itemPhoneInfo
    }
}
