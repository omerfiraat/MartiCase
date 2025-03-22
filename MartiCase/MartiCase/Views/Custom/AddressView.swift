//
//  AddressView.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit

final class AddressView: UIView {
    private let addressLabel: UILabel
    
    var address: String? {
        didSet {
            addressLabel.text = address
            // Address boş ya da nil ise addressView'ı gizle
            isHidden = address?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        }
    }
    
    override init(frame: CGRect) {
        self.addressLabel = UILabel()
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        self.addressLabel = UILabel()
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .primary
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        
        addressLabel.textColor = .darkGray
        addressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        addressLabel.numberOfLines = 2
        addressLabel.textAlignment = .center
        addSubview(addressLabel)
        
        addressLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
    }
}
