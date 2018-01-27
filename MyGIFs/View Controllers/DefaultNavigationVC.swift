//
//  DefaultNavigationVC.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

class DefaultNavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // We can also set a default style on the AppDelegate using:
        // UINavigationBar.appearance().barTintColor = UIColor.black
        navigationBar.barTintColor = UIColor.black
        navigationBar.tintColor = UIColor.white
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        /*
        // For iOS 11 Large Title Style
        if #available(iOS 11.0, *) {
            navigationBar.prefersLargeTitles = true
        }
        */
    }
}
