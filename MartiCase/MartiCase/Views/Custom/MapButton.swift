//
//  MapButton.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit

final class MapButton: UIButton {
    
    // MARK: - Initializers
    convenience init(title: String, fontSize: CGFloat, target: Any?, action: Selector) {
        self.init(type: .system)
        setupButton(title: title, fontSize: fontSize, target: target, action: action)
    }
    
    convenience init(image: UIImage?, target: Any?, action: Selector) {
        self.init(type: .system)
        setupButton(image: image, target: target, action: action)
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration Methods
    private func setupButton(title: String? = nil,
                             fontSize: CGFloat = 17,
                             image: UIImage? = nil,
                             target: Any?,
                             action: Selector) {
        
        configureAppearance()
        configureTitle(title: title, fontSize: fontSize)
        configureImage(image: image)
        addAction(target: target, action: action)
    }
    
    private func configureAppearance() {
        self.backgroundColor = .darkGray
        self.tintColor = .primary
        self.layer.cornerRadius = 25
        self.layer.borderColor = UIColor.primary.cgColor
        self.layer.borderWidth = 2
    }
    
    private func configureTitle(title: String?, fontSize: CGFloat) {
        if let title = title {
            self.setTitle(title, for: .normal)
            self.titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: .bold)
        }
    }
    
    private func configureImage(image: UIImage?) {
        if let image = image {
            self.setImage(image, for: .normal)
        }
    }
    
    private func addAction(target: Any?, action: Selector) {
        self.addTarget(target, action: action, for: .touchUpInside)
        self.addTapAnimation()
    }
    
    // MARK: - Animation
    private func addTapAnimation() {
        addTarget(self, action: #selector(animateTap), for: .touchUpInside)
    }
    
    @objc private func animateTap() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.alpha = 0.8
        }) { _ in
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity
                self.alpha = 1.0
            }
        }
    }
}
