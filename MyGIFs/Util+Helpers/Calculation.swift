//
//  Calculation.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

enum Calculation {
    
    static func heightForWidth(_ targetWidth: CGFloat, originalWidth: Float, originalHeight: Float) -> CGFloat {
        let scaleFactor  = targetWidth / CGFloat(originalWidth)
        let newHeight  = CGFloat(originalHeight) * scaleFactor
        return newHeight
    }
}
