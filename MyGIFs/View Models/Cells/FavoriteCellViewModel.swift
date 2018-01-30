//
//  FavoriteCellViewModel.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 27/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import RxDataSources

struct FavoriteCellViewModel: IdentifiableType, Equatable {
    var identity: String {
        return id
    }
    
    var id: String
    var localImageFileName: String
    var url: String
    var width: Float
    var height: Float
    var size: Float

    var originalModel: LocalGif
    
    var imageData: Data? {
        return PersistGif.shared.imageData(forFileName: localImageFileName)
    }
    
    init(model: LocalGif) {
        id = model.id ?? ""
        localImageFileName = model.localImageFileName ?? ""
        width = model.localImageWidth
        height = model.localImageHeight
        size = model.localImageSize
        url = model.bitlyUrl ?? ""
        originalModel = model
    }
    
    func deleteFavorite() -> Bool {
        if MyGifsCoreData.shared.deleteByObject(originalModel) {
            _ = PersistGif.shared.removeImage(fileName: "\(localImageFileName)")
            return true
        }
        return false
    }
    
    static func ==(lhs: FavoriteCellViewModel, rhs: FavoriteCellViewModel) -> Bool {
        return lhs.identity == rhs.identity
    }
}
