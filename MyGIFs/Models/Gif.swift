//
//  Gif.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreData

// MARK: Initializer and Properties
struct Gif: Mappable {
    
    // MARK: - Attributes
    var id: String!
    var type: String? // gif
    var url: String?
    var bitlyUrl: String?
    var bitlyGifUrl: String?
    var importDatetime: String?
    
    var username: String?
    var title: String?
    var caption: String?

    var fixedWidth: GifSize!
    var original: GifSize?
    var downsizedLarge: GifSize?
    var isFavorite: Bool = false
    
    // MARK: - JSON
    init?(map: Map) {
        // check if a required "id" property exists within the JSON.
        // Not checking the other proprieties trusting the JSON return is alright
        if map.JSON["id"] == nil {
            return nil
        }
        
        if map.JSON["images"] == nil {
            return nil
        }
    }
    
    mutating func mapping(map: Map) {
        id <- map["id"]
        type <- map["type"]
        url <- map["url"]
        bitlyUrl <- map["bitly_url"]
        bitlyGifUrl <- map["bitly_gif_url"]
        
        username <- map["username"]
        title <- map["title"]
        caption <- map["caption"]

        importDatetime <- map["import_datetime"]
        fixedWidth <- map["images.fixed_width"]
        original <- map["images.original"]
        downsizedLarge <- map["images.downsized_large"]
    }
}
