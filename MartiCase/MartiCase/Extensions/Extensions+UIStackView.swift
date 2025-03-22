//
//  Extensions+UIStackView.swift
//  MartiCase
//
//  Created by Ömer Firat on 22.03.2025.
//

import UIKit
 extension UIStackView {
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
}
