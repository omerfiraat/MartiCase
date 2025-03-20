//
//  CustomAnnotation.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import MapKit

class CustomAnnotation: MKPointAnnotation, Codable {
    var address: String?
    
    init(coordinate: CLLocationCoordinate2D, address: String?) {
        super.init()
        self.coordinate = coordinate
        self.address = address
        self.title = "📍 \(address ?? "Bilinmeyen Adres")"
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case address
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.address = try container.decode(String?.self, forKey: .address)
        self.title = "📍 \(self.address ?? "Bilinmeyen Adres")"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(address, forKey: .address)
    }
}
