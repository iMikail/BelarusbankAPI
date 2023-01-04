//
//  ATMAnnotation.swift
//  task4
//
//  Created by Misha Volkov on 29.12.22.
//

import MapKit

final class ATMAnnotation: NSObject, MKAnnotation {
    let addressLine: String
    let currency: String
    let availability: [String]
    let cashIn: Bool

    let coordinate: CLLocationCoordinate2D

    init(fromATM atm: ATM) {
        addressLine = atm.address.addressLine
        currency = atm.currency
        availability = atm.availability.standardAvailability.day.map { $0.openingTime }
        cashIn = true //-
        if let latitude = Double(atm.address.geolocation.geographicCoordinates.latitude),
           let longitude = Double(atm.address.geolocation.geographicCoordinates.longitude) {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            coordinate = CLLocationCoordinate2D()
        }
    }
}
