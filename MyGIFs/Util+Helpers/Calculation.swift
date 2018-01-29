//
//  Calculation.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

enum Calculation {
    
    static func heightForWidth(_ targetWidth: Float, originalWidth: Float, originalHeight: Float) -> Float {
        let scaleFactor  = targetWidth / originalWidth
        let newHeight  = originalHeight * scaleFactor
        return newHeight
    }
}
