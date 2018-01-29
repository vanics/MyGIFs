//
//  FavoritesVM.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation

class FavoritesViewModel {

    private(set) var gifs: [LocalGif] = []

    // MARK: Outputs
    var numberOfSections: Int = 0

    
    func loadData() {
        gifs = MyGifsCoreData.shared.fetchAll()
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return gifs.count
    }
    
    func cellForIndexPath(_ indexPath: IndexPath) -> LocalGif {
        return gifs[indexPath.row]
    }
    
    func heightForCellAtIndexPath(_ indexPath: IndexPath, withAvailableWidth availableWidth: Float) -> Float {
        let localGif = gifs[indexPath.row]
        
        let heightForCell = Calculation.heightForWidth(availableWidth, originalWidth: localGif.localImageWidth, originalHeight: localGif.localImageHeight)
        
        return heightForCell
    }
    
    func deleteFavorite(forCell cell: FavoriteCVCell, at indexPath: IndexPath)  -> Bool {
        guard let object = cell.localGif,
            let localImageFileName = object.localImageFileName else {
                return false
        }
        
        if MyGifsCoreData.shared.deleteByObject(object) {
            _ = PersistGif.shared.removeImage(fileName: "\(localImageFileName)")
        }
        
        gifs.remove(at: indexPath.row)

        return true
    }


}
