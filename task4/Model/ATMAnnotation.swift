//
//  ATMAnnotation.swift
//  task4
//
//  Created by Misha Volkov on 29.12.22.
//

import MapKit

final class ATMAnnotation: NSObject, MKAnnotation {
    var title: String?
    let id: String
    let installPlace: String
    let currency: String
    let workTime: String
    let cashIn: String

    let coordinate: CLLocationCoordinate2D

    init(fromATM atm: ATM) {
        title = "Банкомат"
        id = atm.id
        installPlace = atm.installPlace
        currency = atm.currency
        workTime = atm.workTime //full?
        cashIn = atm.cashIn
        if let latitude = Double(atm.latitude),
           let longitude = Double(atm.longitude) {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = CLLocationCoordinate2D()
        }
    }
}
