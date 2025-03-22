//
//  Extensions+UIViewController.swift
//  MartiCase
//
//  Created by Ömer Firat on 22.03.2025.
//

import UIKit

extension UIViewController {
    
    private func showBlockingView() -> UIView {
        let blockingView = UIView(frame: self.view.bounds)
        blockingView.backgroundColor = UIColor.clear
        self.view.addSubview(blockingView)
        return blockingView
    }
    
    func showToast(message: String, duration: TimeInterval = 2.0) {
        let blockingView = showBlockingView()
        
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.textAlignment = .center
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        toastLabel.frame = CGRect(x: 20, y: self.view.frame.size.height - 100, width: self.view.frame.size.width - 40, height: 40)
        self.view.addSubview(toastLabel)
        
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: [], animations: {
                toastLabel.alpha = 0
            }) { _ in
                toastLabel.removeFromSuperview()
                blockingView.removeFromSuperview()
            }
        }
    }
}
