//
//  BindingTextField.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 27/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

class BindingTextField : UITextField {
    
    var textChanged: (String) -> () = { _ in }
    
    func bind(callback: @escaping (String) -> ()) {
        
        self.textChanged = callback
        self.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        self.textChanged(textField.text!)
    }
    
}
