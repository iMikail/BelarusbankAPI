//
//  ATMAnnotation.swift
//  task4
//
//  Created by Misha Volkov on 29.12.22.
//

import MapKit

final class ElementAnnotation: NSObject, MKAnnotation {
    let element: ElementResponse
    var coordinate: CLLocationCoordinate2D {
        if let latitude = Double(element.latitude), let longitude = Double(element.longitude) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            return CLLocationCoordinate2D()
        }
    }

    init(fromElement element: ElementResponse) {
        self.element = element
    }
}
