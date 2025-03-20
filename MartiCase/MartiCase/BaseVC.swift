//
//  BaseVC.swift
//  MartiCase
//
//  Created by Ömer Firat on 20.03.2025.
//

import UIKit

class BaseVC: UIViewController {
    
    var titleText: String? {
        didSet {
            navigationItem.title = titleText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.view.backgroundColor = .darkGray
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .darkGray
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.primary]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.primary]
        appearance.shadowColor = nil
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }
}
