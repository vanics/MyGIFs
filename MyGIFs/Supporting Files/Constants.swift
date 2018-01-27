//
//  Constants.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation

enum API {
    enum Giphy {
        // Giphy Key Token
        static let APIToken = "X3mqhDeyN6Y5hV2tLToHzsCe5356DNmq"
        static let limitPerRequest = 15
    }
}

enum GIF {
    static let memoryLimitOnFavorites = 200 // 200 MB
    
    // Allow frame skipping to optimize CPU and memory usage
    static let levelOfIntegrity: Float = 0.6 // 1 - 0.1    
}

