//
//  UIViewController+Ext.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Util to show alerts
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: ({
            _ in
            completion?()
        })))
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Share GIF functionality
    func shareGif(imageData: Data) {
        let vc = UIActivityViewController(activityItems: [imageData], applicationActivities: [])
        present(vc, animated: true)
    }
    
    /// Implements dissmiss keyboard when the user taps outside keyboard
    func setupDismissKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
}
