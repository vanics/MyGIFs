//
//  UIColor+Ext.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
    
    // Helper function to convert from RGB to UIColor
    static func rgb(_ rgbValue: UInt, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
    
    static var randomFlat: UIColor {
        let flatColors: [UInt] = [0x3498db, 0x2980b9, 0x27ae60, 0x2ecc71, 0x16a085, 0x1abc9c, 0x9b59b6, 0x8e44ad, 0xf1c40f, 0xf39c12, 0xe67e22, 0xd35400, 0xe74c3c, 0xc0392b, 0xbdc3c7, 0x95a5a6, 0x7f8c8d, 0x34495e, 0x2c3e50]
        
        return UIColor.rgb(UInt(arc4random_uniform(UInt32(flatColors.count))))
    }
}
