//
//  GifSize.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: Initializer and Properties
struct GifSize: Mappable {
    
    var url: String!
    var width: String!
    var height: String!
    var size: String?
    
    // MARK: JSON
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        url <- map["url"]
        width <- map["width"]
        height <- map["height"]
        size <- map["size"]
    }
    
    func heightForWidth(_ targetWidth: CGFloat) -> CGFloat {
        let scaleFactor  = targetWidth / CGFloat(Float(width)!)
        let newHeight  = CGFloat(Float(height)!) * scaleFactor
        return newHeight
    }
}

