//
//  FavoriteCVCell.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

protocol FavoriteActionsDelegate: class {
    func deleteFavorite(_ object: LocalGif)
}

class FavoriteCVCell: UICollectionViewCell {
    @IBOutlet weak var gifImageView: UIImageView!
    
    weak var favoriteActionsDelegate: FavoriteActionsDelegate?
    
    var localGif: LocalGif? {
        didSet {
            
        }
    }
    
    @IBAction func favoriteBtnDidTouch(_ sender: UIButton) {
        guard let localGif = localGif else {
            return
        }
        
        favoriteActionsDelegate?.deleteFavorite(localGif)
    }
}
