//
//  LocationManager.swift
//  MartiCase
//
//  Created by Ömer Firat on 22.03.2025.
//

import CoreLocation

final class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    // Callback closure for location updates
    var didUpdateLocations: (([CLLocation]) -> Void)?
    var didFailWithError: ((Error) -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }

    func startUpdatingLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations?(locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError?(error)
    }
}
