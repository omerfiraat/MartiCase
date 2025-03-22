//
//  Extensions+UIView.swift
//  MartiCase
//
//  Created by Ömer Firat on 22.03.2025.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { addSubview($0) }
    }
}
