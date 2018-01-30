//
//  FeedCellViewModel.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 27/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import RxSwift

struct FeedCellViewModel {
    // MARK: - Public Interface
    var id: String
    var width: Float
    var height: Float
    var imageUrl: String
    var isFavorite = Variable(false)
    
    // Accordingly to MVVM principles view should not be
    // aware of Model. That assures reusability.
    // Which means that we should copy all the models variables
    // that we want to show to the view
    
    private var originalModel: Gif
    
    init(model: Gif) {
        id = model.id
        width = model.fixedWidth.width
        height = model.fixedWidth.width
        imageUrl = model.fixedWidth.url
        isFavorite.value = MyGifsCoreData.shared.retrieveById(id)
        
        originalModel = model
    }
    
    // MARK: - Public Actions
    func favoriteImage(imageData: Data) {
        if !isFavorite.value {
            addToFavorites(imageData: imageData)
        } else {
            removeFromFavorites()
        }

    }
    
    // Force isFavorite update
    // Usually in the case the screen was reloaded
    func syncData() {
        isFavorite.value = MyGifsCoreData.shared.retrieveById(id)
    }
    
    // MARK: - Private
    
    private func addToFavorites(imageData: Data) {
        if let imagePath = PersistGif.shared.storeLocalImage(name: id, imageData: imageData) {
            MyGifsCoreData.shared.insertItem(originalModel, imagePath: imagePath)
        }
        
        isFavorite.value = true
    }
    
    private func removeFromFavorites() {
        // TODO: Invert it
        if MyGifsCoreData.shared.deleteById(id) {
            _ = PersistGif.shared.removeImage(fileName: "\(id).gif")
        }
        
        isFavorite.value = false
    }
}
