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
    var width: Float?
    var height: Float?
    var size: Float?
    
    // MARK: JSON
    init?(map: Map) { }
    
    mutating func mapping(map: Map) {
        url <- map["url"]
        width <- (map["width"], transform)
        height <- (map["height"], transform)
        size <- (map["size"], transform)
    }
    
    func heightForWidth(_ targetWidth: CGFloat) -> CGFloat {
        return Calculation.heightForWidth(
            targetWidth,
            originalWidth: width!,
            originalHeight: height!
        )
    }
}

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

