//
//  MKMapView.swift
//  task4
//
//  Created by Misha Volkov on 29.12.22.
//

import MapKit

extension MKMapView {
    internal var belarusRegion: MKCoordinateRegion {
        let coordinate = CLLocationCoordinate2D(latitude: 53.34165599999997, longitude: 28.02366599999999)
        let span = MKCoordinateSpan(latitudeDelta: 9.225576478261104, longitudeDelta: 9.7583020000001)
        return MKCoordinateRegion(center: coordinate, span: span)
    }

    internal func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}
