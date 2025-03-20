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

// MARK: - Notification Names
extension Notification.Name {
    static let addMarker = Notification.Name("addMarker")
}

// MARK: - CustomMapView
class CustomMapView: UIView {
    
    // MARK: - Properties
    private var mapView: MKMapView!
    private var zoomInButton: UIButton!
    private var zoomOutButton: UIButton!
    private var currentLocationButton: UIButton!
    private var clearMarkersButton: UIButton!  // Add the button property
    private var viewModel: MapViewModel!
    var selectedAnnotation: CustomAnnotation?
    private var directions: MKDirections?
    weak var delegate: CustomMapViewDelegate?
    
    // MARK: - Init
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
    
    // MARK: - Setup UI
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
        zoomInButton = createZoomButton(title: "+", action: #selector(zoomIn))
        zoomOutButton = createZoomButton(title: "-", action: #selector(zoomOut))
        currentLocationButton = createLocationButton(action: #selector(goToCurrentLocation))
        clearMarkersButton = createClearMarkersButton()  // Initialize the Clear Markers button
        
        addSubview(zoomInButton)
        addSubview(zoomOutButton)
        addSubview(currentLocationButton)
        addSubview(clearMarkersButton)  // Add the button to the view
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
    
    // MARK: - Button Creation
    private func createZoomButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .darkGray
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 36)
        button.tintColor = .primary
        button.layer.cornerRadius = 25
        button.layer.borderColor = UIColor.primary.cgColor
        button.layer.borderWidth = 2
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func createLocationButton(action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.backgroundColor = .darkGray
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.tintColor = .primary
        button.layer.cornerRadius = 25
        button.layer.borderColor = UIColor.primary.cgColor
        button.layer.borderWidth = 2
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func createClearMarkersButton() -> UIButton {  // Method to create Clear Markers button
        let button = UIButton(type: .system)
        button.backgroundColor = .darkGray
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .primary
        button.layer.cornerRadius = 25
        button.layer.borderColor = UIColor.primary.cgColor
        button.layer.borderWidth = 2
        button.addTarget(self, action: #selector(clearMarkers), for: .touchUpInside)
        return button
    }
    
    // MARK: - Clear Markers Action
    @objc private func clearMarkers() {
        mapView.removeAnnotations(mapView.annotations) // Tüm markerları temizle
        mapView.removeOverlays(mapView.overlays)       // Çizilmiş rotaları temizle
        directions?.cancel()                            // Devam eden yönlendirmeyi iptal et
    }
    
    // MARK: - Zoom Actions
    @objc private func zoomIn() {
        adjustMapZoom(by: 0.66)
    }
    
    @objc private func zoomOut() {
        adjustMapZoom(by: 1.5)
    }
    
    private func adjustMapZoom(by factor: CGFloat) {
        animateButton(zoomInButton)
        
        var region = mapView.region
        region.span.latitudeDelta *= factor
        region.span.longitudeDelta *= factor
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Animation Helper
    private func animateButton(_ button: UIButton) {
        UIView.animate(withDuration: 0.2, animations: {
            button.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            button.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                button.transform = CGAffineTransform.identity
                button.alpha = 1.0
            }
        }
    }
    
    // MARK: - Current Location Action
    @objc private func goToCurrentLocation() {
        animateButton(currentLocationButton)
        
        guard let userCoordinate = viewModel.userLocation else { return }
        
        let region = MKCoordinateRegion(
            center: userCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - Route Actions
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
                self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50), animated: true)
            } else if let error = error {
                print("Route error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Address Alert
    private func showAddressAlert(address: String) {
        let alert = UIAlertController(
            title: "Address Information",
            message: address,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Create Route", style: .default) { [weak self] _ in
            if let annotation = self?.selectedAnnotation as? CustomAnnotation {
                self?.showRoute(to: annotation.coordinate)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        self.window?.rootViewController?.present(alert, animated: true)
    }
    
    // MARK: - ViewModel Binding
    // In CustomMapView.swift
    private func setupBindings() {
        NotificationCenter.default.addObserver(self, selector: #selector(addMarker(_:)), name: .addMarker, object: nil)
        
        // Add existing saved markers to the map
        let savedMarkers = viewModel.getSavedMarkers()
        mapView.addAnnotations(savedMarkers)
    }
    
    // MARK: - Add Marker
    @objc private func addMarker(_ notification: Notification) {
        guard let annotation = notification.object as? CustomAnnotation else { return }
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Map Region Update
    func updateMapRegion() {
        guard let region = viewModel.getMapRegion() else { return }
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - MKMapViewDelegate
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
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer()
    }
}
