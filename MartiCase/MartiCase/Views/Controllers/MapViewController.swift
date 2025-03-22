//
//  MapViewController.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit
import MapKit
import SnapKit

final class MapViewController: BaseVC {
    
    // MARK: - Constants
    private enum Constants {
        enum Button {
            static let size: CGFloat = 48
            static let insets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        }
        enum AddressView {
            static let height: CGFloat = 60
            static let bottomOffset: CGFloat = -16
        }
        enum ActionStack {
            static let spacing: CGFloat = 12
            static let height: CGFloat = 48
        }
        enum Images {
            static let locationActive = "location.fill"
            static let locationInactive = "location.slash.fill"
            static let appleLogo = "applelogo"
        }
        enum Messages {
            static let locationTrackingStarted = "Your location is now being tracked."
            static let locationTrackingStopped = "Location tracking has been stopped."
        }
    }
    
    // MARK: - Properties
    private var customMapView: CustomMapView!
    private lazy var viewModel = MapViewModel()
    private var addressView: AddressView!
    
    // UI Components
    private lazy var actionButton = ActionButton(
        title: "Create Route",
        action: #selector(handleRouteButtonTapped)
    )
    
    private lazy var appleMapsButton = ActionButton(
        systemName: Constants.Images.appleLogo,
        action: #selector(openInAppleMaps)
    )
    
    private lazy var locationToggleButton = ActionButton(
        systemName: Constants.Images.locationActive,
        action: #selector(toggleLocationTracking)
    )
    
    private let actionStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = Constants.ActionStack.spacing
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText = "Marti Case"
        
        configureHierarchy()
        configureConstraints()
        configureState()
        
        viewModel.startTrackingUserLocation()
        updateActionButtonState()
    }
    
    // MARK: - Configuration
    private func configureHierarchy() {
        customMapView = CustomMapView(viewModel: viewModel)
        customMapView.delegate = self
        
        addressView = AddressView()
        addressView.isHidden = true
        
        view.addSubviews(customMapView, addressView, actionStackView)
        actionStackView.addArrangedSubviews(locationToggleButton, actionButton, appleMapsButton)
    }
    
    private func configureConstraints() {
        customMapView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(addressView.snp.top).offset(Constants.Button.insets.bottom)
        }
        
        addressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Constants.Button.insets)
            make.height.equalTo(Constants.AddressView.height)
            make.bottom.equalTo(actionStackView.snp.top).offset(Constants.AddressView.bottomOffset)
        }
        
        actionStackView.snp.makeConstraints { make in
            make.height.equalTo(Constants.ActionStack.height)
            make.leading.trailing.equalToSuperview().inset(Constants.Button.insets)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(Constants.Button.insets)
        }
        
        locationToggleButton.snp.makeConstraints { make in
            make.width.equalTo(Constants.Button.size)
        }
        
        appleMapsButton.snp.makeConstraints { make in
            make.width.equalTo(Constants.Button.size)
        }
    }
    
    private func configureState() {
        loadLocationTrackingStatus()
    }
    
    // MARK: - State Management
    func updateActionButtonState() {
        let hasMarkers = viewModel.hasSavedMarkers()
        actionButton.isEnabled = hasMarkers
        appleMapsButton.isHidden = !hasMarkers
    }
    
    private func loadLocationTrackingStatus() {
        viewModel.loadLocationTrackingStatus { [weak self] isActive in
            self?.updateLocationButtonImage(isActive: isActive)
        }
    }
    
    private func updateLocationButtonImage(isActive: Bool) {
        let imageName = isActive ? Constants.Images.locationActive : Constants.Images.locationInactive
        locationToggleButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    // MARK: - Actions
    @objc private func handleRouteButtonTapped() {
        guard let annotation = customMapView.selectedAnnotation else { return }
        customMapView.showRoute(to: annotation.coordinate)
    }
    
    @objc private func openInAppleMaps() {
        guard let annotation = customMapView.selectedAnnotation else { return }
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
        mapItem.name = "Selected Location"
        mapItem.openInMaps()
    }
    
    @objc private func toggleLocationTracking() {
        viewModel.toggleLocationTracking { [weak self] isActive in
            self?.updateLocationButtonImage(isActive: isActive)
            
            let message = isActive ? Constants.Messages.locationTrackingStarted : Constants.Messages.locationTrackingStopped
            self?.showToast(message: message)
        }
    }
}

// MARK: - CustomMapViewDelegate
extension MapViewController: CustomMapViewDelegate {
    func didSelectLocation(address: String) {
        addressView.isHidden = address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        appleMapsButton.isHidden = addressView.isHidden
        actionButton.isEnabled = !addressView.isHidden
        addressView.address = address
    }
}
