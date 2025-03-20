//
//  MapViewModel.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit
import CoreLocation
import MapKit

class MapViewModel: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    private var lastMarkerLocation: CLLocation?
    var userLocation: CLLocationCoordinate2D? // Kullanıcı konumu
    var currentUserLocation: CLLocationCoordinate2D? // Rota için kullanılacak
    private var savedMarkers: [CustomAnnotation] = [] // Marker'ları saklamak için dizi
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.allowsBackgroundLocationUpdates = true // Arka planda konum güncellemelerini al
        locationManager.startUpdatingLocation()
        loadSavedMarkers()
    }
    
    // Kullanıcı konumunu takip etmeye başlar
    func startTrackingUserLocation() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        locationManager.startUpdatingLocation()
    }
    
    // Kullanıcı konumunu takip etmeyi durdurur
    func stopTrackingUserLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // Kullanıcı konumu güncellendiğinde çalışır
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        userLocation = newLocation.coordinate
        currentUserLocation = newLocation.coordinate // Güncel konum

        // Marker'ı sadece 100 metreden fazla mesafe değiştiğinde ekle
        if let lastLocation = lastMarkerLocation {
            let distance = newLocation.distance(from: lastLocation)
            if distance >= 100 {
                addMarker(at: newLocation.coordinate)
                lastMarkerLocation = newLocation
            }
        } else {
            addMarker(at: newLocation.coordinate)
            lastMarkerLocation = newLocation
        }
    }
    
    // Marker ekler ve geocoding ile adresi bulur
    private func addMarker(at coordinate: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            var addressString = "Adres bulunamadı"
            if let placemark = placemarks?.first {
                addressString = [
                    placemark.thoroughfare,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
            }
            
            // Yeni marker'ı listeye ekle
            let newMarker = CustomAnnotation(coordinate: coordinate, address: addressString)
            self.savedMarkers.append(newMarker)
            
            // Marker'ı kaydet
            self.saveMarkers()
            
            // Marker ekleme bildirimini gönder
            NotificationCenter.default.post(
                name: .addMarker,
                object: newMarker
            )
        }
    }
    
    // Konum hatası alındığında çağrılır
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    // Harita regionunu kullanıcının konumuna göre döner
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
    
    // Saved Marker'ları dışarıya sunma
    func getSavedMarkers() -> [CustomAnnotation] {
        return savedMarkers
    }
    
    // Saved Marker'ları kaydetme
    func saveMarkers() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(savedMarkers) {
            UserDefaults.standard.set(encoded, forKey: "savedMarkers")
        }
    }
    
    // Kaydedilen Marker'ları yükleme
    func loadSavedMarkers() {
        if let savedData = UserDefaults.standard.data(forKey: "savedMarkers") {
            let decoder = JSONDecoder()
            if let markers = try? decoder.decode([CustomAnnotation].self, from: savedData) {
                savedMarkers = markers
            }
        }
    }
}
