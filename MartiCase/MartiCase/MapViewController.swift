import UIKit
import MapKit
import SnapKit

class MapViewController: BaseVC {
    
    // MARK: - Properties
    private var customMapView: CustomMapView!
    private let viewModel = MapViewModel()
    private var selectedAddress: String? {
        didSet {
            addressLabel.text = selectedAddress
            addressView.isHidden = (selectedAddress == nil)
        }
    }
    
    private let addressView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.isHidden = true
        return view
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rota Oluştur", for: .normal)
        button.backgroundColor = .primary
        button.layer.cornerRadius = 12
        button.setTitleColor(.darkGray, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        titleText = "Maps"
        
        customMapView = CustomMapView(viewModel: viewModel)
        customMapView.delegate = self
        
        view.addSubview(customMapView)
        view.addSubview(addressView)
        addressView.addSubview(addressLabel)
        view.addSubview(actionButton)
        
        setupConstraints()
        
        viewModel.startTrackingUserLocation()
    }
    
    // MARK: - ViewModel Binding
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        customMapView.updateMapRegion()
    }
    
    private func setupConstraints() {
        customMapView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(addressView.snp.top).offset(-16)
        }
        
        addressView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
            make.bottom.equalTo(actionButton.snp.top).offset(-16)
        }
        
        addressLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        actionButton.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
        }
        
        actionButton.addTarget(self, action: #selector(handleRouteButtonTapped), for: .touchUpInside)
    }
    
    @objc private func handleRouteButtonTapped() {
        guard let annotation = customMapView.selectedAnnotation else { return }
        customMapView.showRoute(to: annotation.coordinate)
    }
}

// MARK: - CustomMapViewDelegate
extension MapViewController: CustomMapViewDelegate {
    func didSelectLocation(address: String) {
        selectedAddress = address
    }
}
