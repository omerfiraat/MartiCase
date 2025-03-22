//
//  ActionButton.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit

final class ActionButton: UIButton {
    
    // MARK: - Initializers
    init(title: String? = nil, systemName: String? = nil, action: Selector? = nil) {
        super.init(frame: .zero)
        
        // Configure title if provided
        if let title = title, !title.isEmpty {
            setTitle(title, for: .normal)
            titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
            setTitleColor(.darkGray, for: .normal)
        }
        
        // Configure icon if provided
        if let systemName = systemName {
            let icon = UIImage(systemName: systemName)?.withRenderingMode(.alwaysTemplate)
            setImage(icon, for: .normal)
            tintColor = .darkGray
        }
        
        backgroundColor = .primary
        layer.cornerRadius = 12
        
        // Add action if provided
        if let action = action {
            addTarget(nil, action: action, for: .touchUpInside)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // Override isEnabled to change appearance when disabled.
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .primary : .lightGray
            setTitleColor(isEnabled ? .darkGray : .gray, for: .normal)
        }
    }
}
