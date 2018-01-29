//
//  GifSize.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import ObjectMapper

struct GifSize: Mappable {
    
    // MARK: - Attributes
    var url: String!
    var width: Float!
    var height: Float!
    var size: Float!
    
    // MARK: - JSON
    init?(map: Map) {
        if map.JSON["url"] == nil {
            return nil
        }
        
        if map.JSON["width"] == nil {
            return nil
        }
        
        if map.JSON["height"] == nil {
            return nil
        }
        
        if map.JSON["size"] == nil {
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        url <- map["url"]
        width <- (map["width"], transform)
        height <- (map["height"], transform)
        size <- (map["size"], transform)
    }
}

// Util Transformer to convert String into Float
fileprivate let transform = TransformOf<Float, String>(fromJSON: { (value) in
    
    if let value = value {
        return Float(value)
    }
    
    return nil
}, toJSON: { value in
    if let value = value {
        return String(value)
    }
    return nil
})

