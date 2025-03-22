//
//  CustomMapView.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit
import MapKit
import SnapKit

protocol CustomMapViewDelegate: AnyObject {
    func didSelectLocation(address: String)
}

extension Notification.Name {
    static let addMarker = Notification.Name("addMarker")
}

final class CustomMapView: UIView {
    
    private var mapView: MKMapView!
    private var zoomInButton: MapButton!
    private var zoomOutButton: MapButton!
    private var currentLocationButton: MapButton!
    private var clearMarkersButton: MapButton!
    
    private var viewModel: MapViewModel!
    var selectedAnnotation: CustomAnnotation?
    private var directions: MKDirections?
    
    weak var delegate: CustomMapViewDelegate?
    
    init(viewModel: MapViewModel) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        setupUI()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        setupMapView()
        setupButtons()
        setupConstraints()
    }
    
    private func setupMapView() {
        mapView = MKMapView()
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.layer.cornerRadius = 18
        mapView.layer.borderColor = UIColor.primary.cgColor
        mapView.layer.borderWidth = 8
        addSubview(mapView)
    }
    
    private func setupButtons() {
        zoomInButton = MapButton(
            title: "+",
            fontSize: 36,
            target: self,
            action: #selector(zoomIn)
        )
        
        zoomOutButton = MapButton(
            title: "-",
            fontSize: 36,
            target: self,
            action: #selector(zoomOut)
        )
        
        currentLocationButton = MapButton(
            image: UIImage(systemName: "location.fill"),
            target: self,
            action: #selector(goToCurrentLocation)
        )
        
        clearMarkersButton = MapButton(
            image: UIImage(systemName: "trash"),
            target: self,
            action: #selector(clearMarkers)
        )
        
        [zoomInButton, zoomOutButton, currentLocationButton, clearMarkersButton].forEach { addSubview($0) }
    }
    
    private func setupConstraints() {
        mapView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            make.width.equalToSuperview().offset(-32)
            make.centerX.equalToSuperview()
            make.height.equalTo(mapView.snp.width)
        }
        
        zoomInButton.snp.makeConstraints { make in
            make.bottom.equalTo(mapView.snp.bottom).offset(-20)
            make.right.equalTo(mapView.snp.right).offset(-20)
            make.width.height.equalTo(50)
        }
        
        zoomOutButton.snp.makeConstraints { make in
            make.bottom.equalTo(zoomInButton.snp.top).offset(-10)
            make.right.equalTo(mapView.snp.right).offset(-20)
            make.width.height.equalTo(50)
        }
        
        currentLocationButton.snp.makeConstraints { make in
            make.bottom.equalTo(mapView.snp.bottom).offset(-20)
            make.left.equalTo(mapView.snp.left).offset(20)
            make.width.height.equalTo(50)
        }
        
        clearMarkersButton.snp.makeConstraints { make in
            make.bottom.equalTo(currentLocationButton.snp.top).offset(-10)
            make.left.equalTo(mapView.snp.left).offset(20)
            make.width.height.equalTo(50)
        }
    }
    
    @objc private func zoomIn() {
        adjustMapZoom(by: 0.66)
    }
    
    @objc private func zoomOut() {
        adjustMapZoom(by: 1.5)
    }
    
    @objc private func goToCurrentLocation() {
        guard viewModel.userLocation != nil else { return }

        if let region = viewModel.getMapRegion() {
            mapView.setRegion(region, animated: true)
        }
    }
    
    @objc private func clearMarkers() {
        let alertController = UIAlertController(
            title: "Delete All Markers",
            message: "Are you sure you want to delete all markers?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.removeOverlays(self.mapView.overlays)
            self.delegate?.didSelectLocation(address: "")
            self.directions?.cancel()
            UserDefaults.standard.removeObject(forKey: "savedMarkers")
            UserDefaults.standard.synchronize()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        if let viewController = self.window?.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func adjustMapZoom(by factor: CGFloat) {
        var region = mapView.region
        region.span.latitudeDelta *= factor
        region.span.longitudeDelta *= factor
        mapView.setRegion(region, animated: true)
    }
    
    func showRoute(to coordinate: CLLocationCoordinate2D) {
        guard let userLocation = viewModel.currentUserLocation else { return }
        mapView.removeOverlays(mapView.overlays)
        directions?.cancel()
        
        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
        let destinationPlacemark = MKPlacemark(coordinate: coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .walking
        
        directions = MKDirections(request: request)
        directions?.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            if let route = response?.routes.first {
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                let rect = route.polyline.boundingMapRect
                self.mapView.setVisibleMapRect(
                    rect,
                    edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50),
                    animated: true
                )
            }
        }
    }
    
    private func setupBindings() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addMarker(_:)),
            name: .addMarker,
            object: nil
        )
        let savedMarkers = viewModel.getSavedMarkers()
        mapView.addAnnotations(savedMarkers)
    }
    
    @objc private func addMarker(_ notification: Notification) {
        guard let annotation = notification.object as? CustomAnnotation else { return }
        mapView.addAnnotation(annotation)
    }
    
    func updateMapRegion() {
        guard let region = viewModel.getMapRegion() else { return }
        mapView.setRegion(region, animated: true)
    }
}

extension CustomMapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? CustomAnnotation else { return }
        selectedAnnotation = annotation
        if let address = annotation.address {
            delegate?.didSelectLocation(address: address)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .primary
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
}
