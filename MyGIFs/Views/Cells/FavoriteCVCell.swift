//
//  FavoriteCVCell.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit
import SwiftyGif

protocol FavoriteActionsDelegate: class {
    var gifManager: SwiftyGifManager { get }
    func deleteFavorite(forCell cell: FavoriteCVCell)
}

class FavoriteCVCell: UICollectionViewCell {
    @IBOutlet weak var gifImageView: UIImageView!
    
    weak var favoriteActionsDelegate: FavoriteActionsDelegate?
    
    var localGif: LocalGif? {
        didSet {
            if let gifManager = favoriteActionsDelegate?.gifManager,
                let localImageFileName = localGif?.localImageFileName,
                let imageData = PersistGif.shared.imageData(forFileName: localImageFileName) {
                // TODO: Encapsulate this and send using Depedency Injection
                // Making this cell more reusable?
                                
                let gif = UIImage(gifData: imageData, levelOfIntegrity: GIF.levelOfIntegrity)
                gifImageView.setGifImage(gif, manager: gifManager)
            }
        }
    }
    
    override func prepareForReuse() {
        gifImageView.image = nil
    }
    
    @IBAction func favoriteBtnDidTouch(_ sender: UIButton) {
        favoriteActionsDelegate?.deleteFavorite(forCell: self)
    }
}
