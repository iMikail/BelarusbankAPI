//
//  DetailRouter.swift
//  task4
//
//  Created by Misha Volkov on 20.01.23.
//

import MapKit

protocol DetailRoutingLogic {
    func openMap(element: ElementResponse, userCoordinate: CLLocationCoordinate2D)
}

protocol DetailDataPassing {
    var dataStore: DetailDataStore? { get set }
}

class DetailRouter: NSObject, DetailRoutingLogic, DetailDataPassing {
    weak var viewController: DetailViewController?

    var dataStore: DetailDataStore?

    // MARK: Routing
    func openMap(element: ElementResponse, userCoordinate: CLLocationCoordinate2D) {
        guard let latitude = Double(element.latitude),
              let longitude = Double(element.longitude) else { return }

        let userMapItem = MKMapItem(placemark: MKPlacemark(coordinate: userCoordinate))
        userMapItem.name = "Моё местоположение"

        let atmCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let atmMapItem = MKMapItem(placemark: MKPlacemark(coordinate: atmCoordinate))
        atmMapItem.name = element.elementType.elementName

        MKMapItem.openMaps(with: [userMapItem, atmMapItem],
                           launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}
