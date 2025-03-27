//
//  MapViewModel.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit
import CoreLocation
import MapKit

final class MapViewModel: NSObject {
    
    // MARK: - Properties
    private let locationManager = LocationManager()
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
        setupLocationManagerClosures()
        loadInitialLocationTrackingState()
    }
    
    // MARK: - Location Manager Setup
    private func setupLocationManagerClosures() {
        locationManager.didUpdateLocations = { [weak self] locations in
            self?.handleLocationUpdates(locations)
        }
        
        locationManager.didFailWithError = { error in
            print("Error: \(error.localizedDescription)")
        }
        
        locationManager.didChangeAuthorization = { [weak self] status in
            self?.handleAuthorizationChange(status)
        }
    }
    
    // MARK: - Location Tracking
    func startTrackingUserLocation() {
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopTrackingUserLocation() {
        DispatchQueue.main.async {
            self.locationManager.stopUpdatingLocation()
        }
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
        if isActive {
            startTrackingUserLocation()
        } else {
            stopTrackingUserLocation()
        }
    }
    
    // MARK: - Authorization Handling
    private func handleAuthorizationChange(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startTrackingUserLocation()
        case .denied, .restricted:
            stopTrackingUserLocation()
        default:
            break
        }
    }
    
    // MARK: - Location Updates Handling
    private func handleLocationUpdates(_ locations: [CLLocation]) {
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
        if isTrackingActive {
            startTrackingUserLocation()
        }
    }
}
