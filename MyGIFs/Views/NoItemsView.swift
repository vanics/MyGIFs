//
//  NoItemsView.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 26/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

class NoItemsView: UIView {

    // MARK: - Attributes
    
    var textMessage = "No Items" {
        didSet {
            label.text = textMessage
        }
    }
    
    var label: UILabel = {
        let label = UILabel()
        label.text = "No Items"
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center

        return label
    }()

    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Setup
    
    func setupView() {
        addSubview(label)
        
        label.anchorCenterToSuperview()
    }
}
