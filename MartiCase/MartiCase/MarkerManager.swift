//
//  MarkerManager.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import Foundation

final class MarkerManager {
    
    private var savedMarkers: [CustomAnnotation] = []
    private let markersKey = "savedMarkers"
    
    init() {
        loadMarkers()
    }
    
    /// Adds a new marker, saves the updated list and posts a notification.
    func addMarker(_ marker: CustomAnnotation) {
        savedMarkers.append(marker)
        saveMarkers()
        NotificationCenter.default.post(name: .addMarker, object: marker)
    }
    
    /// Returns all saved markers.
    func getMarkers() -> [CustomAnnotation] {
        return savedMarkers
    }
    
    /// Saves markers to UserDefaults.
    private func saveMarkers() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(savedMarkers) {
            UserDefaults.standard.set(encoded, forKey: markersKey)
        }
    }
    
    /// Loads markers from UserDefaults.
    private func loadMarkers() {
        if let savedData = UserDefaults.standard.data(forKey: markersKey) {
            let decoder = JSONDecoder()
            if let markers = try? decoder.decode([CustomAnnotation].self, from: savedData) {
                savedMarkers = markers
            }
        }
    }
}
