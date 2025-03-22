//
//  MapViewModel.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit
import CoreLocation
import MapKit

final class MapViewModel: NSObject, CLLocationManagerDelegate {
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private var lastMarkerLocation: CLLocation?
    var userLocation: CLLocationCoordinate2D?
    var currentUserLocation: CLLocationCoordinate2D?
    private let trackingKey = "isLocationTrackingActive"
    private let markerManager = MarkerManager()
    
    private var isFirstLocationUpdate = true
    private let minimumDistanceForMarker: CLLocationDistance = 100
    
    // MARK: - Initialization
    override init() {
        super.init()
        locationManager.delegate = self
        setupLocationManager()
        loadInitialLocationTrackingState()
    }
    
    // MARK: - Location Manager Setup
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    // MARK: - Location Tracking
    func startTrackingUserLocation() {
        DispatchQueue.global(qos: .background).async {
            guard CLLocationManager.locationServicesEnabled() else { return }
            
            DispatchQueue.main.async {
                self.locationManager.allowsBackgroundLocationUpdates = true
                self.locationManager.startUpdatingLocation()
            }
        }
    }
    
    func stopTrackingUserLocation() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
    }
    
    func toggleLocationTracking(completion: (Bool) -> Void) {
        let isTrackingActive = !UserDefaults.standard.bool(forKey: trackingKey)
        UserDefaults.standard.set(isTrackingActive, forKey: trackingKey)
        updateLocationTrackingState(isTrackingActive)
        completion(isTrackingActive)
    }
    
    func loadLocationTrackingStatus(completion: (Bool) -> Void) {
        let isActive = UserDefaults.standard.bool(forKey: trackingKey)
        updateLocationTrackingState(isActive)
        completion(isActive)
    }
    
    private func updateLocationTrackingState(_ isActive: Bool) {
        locationManager.allowsBackgroundLocationUpdates = isActive
        if isActive {
            startTrackingUserLocation()
        } else {
            stopTrackingUserLocation()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if isFirstLocationUpdate {
            lastMarkerLocation = newLocation
            isFirstLocationUpdate = false
            return
        }
        
        userLocation = newLocation.coordinate
        currentUserLocation = newLocation.coordinate
        
        if shouldAddNewMarker(for: newLocation) {
            addMarker(at: newLocation.coordinate)
            lastMarkerLocation = newLocation
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startTrackingUserLocation()
        case .denied, .restricted:
            stopTrackingUserLocation()
        default:
            break
        }
    }
    
    // MARK: - Marker Management
    private func shouldAddNewMarker(for newLocation: CLLocation) -> Bool {
        let isTrackingActive = UserDefaults.standard.bool(forKey: trackingKey)
        return isTrackingActive && hasMovedSignificantly(newLocation)
    }
    
    private func hasMovedSignificantly(_ newLocation: CLLocation) -> Bool {
        guard let lastLocation = lastMarkerLocation else { return true }
        let distance = newLocation.distance(from: lastLocation)
        return distance >= minimumDistanceForMarker
    }
    
    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            let addressString = self.constructAddress(from: placemarks?.first)
            let newMarker = CustomAnnotation(coordinate: coordinate, address: addressString)
            self.markerManager.addMarker(newMarker)
        }
    }
    
    private func constructAddress(from placemark: CLPlacemark?) -> String {
        guard let placemark = placemark else { return "Address not found" }
        return [
            placemark.thoroughfare,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ].compactMap { $0 }.joined(separator: ", ")
    }
    
    // MARK: - Map Region Calculation
    func getMapRegion() -> MKCoordinateRegion? {
        guard let userCoordinate = userLocation else { return nil }
        
        let radiusInKm: Double = 1.0
        let latitudeDelta = radiusInKm / 111.0
        let longitudeDelta = latitudeDelta / cos(userCoordinate.latitude * .pi / 180.0)
        
        return MKCoordinateRegion(
            center: userCoordinate,
            span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        )
    }
    
    // MARK: - Marker Access
    func getSavedMarkers() -> [CustomAnnotation] {
        return markerManager.getMarkers()
    }
    
    // MARK: - Helper Methods
    func hasSavedMarkers() -> Bool {
        return !markerManager.getMarkers().isEmpty
    }
    
    // MARK: - Load Initial State
    private func loadInitialLocationTrackingState() {
        let isTrackingActive = UserDefaults.standard.bool(forKey: trackingKey)
        locationManager.allowsBackgroundLocationUpdates = isTrackingActive
        if isTrackingActive {
            startTrackingUserLocation()
        }
    }
}
