//
//  Gif.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK: Initializer and Properties
struct Gif: Mappable {
    
    var id: String!
    var type: String? // gif
    var url: String?
    var bitlyUrl: String?
    var bitlyGifUrl: String?
    var caption: String?
    var importDatetime: String?
    
    var fixedWidth: GifSize?
    var original: GifSize?
    var downsizedLarge: GifSize?

    // MARK: JSON
    init?(map: Map) {
        // check if a required "id" property exists within the JSON.
        // Not checking the other proprieties trusting the JSON return is alright
        if map.JSON["id"] == nil {
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        url <- map["url"]
        bitlyUrl <- map["bitly_url"]
        bitlyGifUrl <- map["bitly_gif_url"]
        caption <- map["caption"]
        importDatetime <- map["import_datetime"]
        fixedWidth <- map["images.fixed_width"]
        original <- map["images.original"]
        downsizedLarge <- map["images.downsized_large"]
    }
}
