//
//  FeedTVCell.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit
import Kingfisher

protocol FeedActionsDelegate: class {
    func addFavorite(item: Gif, imageData: Data)
    func removeFavorite(item: Gif)
}

class FeedTVCell: UITableViewCell {    
    weak var feedActionsDelegate: FeedActionsDelegate?
    
    @IBOutlet private weak var gifImageView: UIImageView!
    @IBOutlet private weak var favoriteBtn: UIButton!
    
    // MARK: - Public Interface
    
    var gif: Gif? {
        didSet {
            backgroundColor = UIColor.randomFlat
            print(UIColor.randomFlat)
            if let imageUrl = gif?.fixedWidth?.url {
                gifImageView?.kf.setImage(with: URL(string: imageUrl))
                setFavoriteBtn(gif!.isFavorite)
            }
        }
    }
    
    func cancelImageDownloadTask() {
        gifImageView?.kf.cancelDownloadTask()
        
        // TODO: Check if it really clears the previous image
        gifImageView?.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setFavoriteBtn(_ isFavorite: Bool) {
        let imageName = (isFavorite) ? "FavoritesFillIcon" : "FavoritesIcon"
        favoriteBtn.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteBtn.imageView?.tintColor = .red
    }
    
    @IBAction private func favoriteBtnDidTouch(_ sender: UIButton) {
        // TODO: Check if the image was loaded
        guard let gif = gif,
            let imageData = gifImageView.kf.base.currentImage?.imageData else {
            return
        }

        setFavoriteBtn(!gif.isFavorite)
        
        if !gif.isFavorite {
            feedActionsDelegate?.addFavorite(item: gif, imageData: imageData)
        } else {
            feedActionsDelegate?.removeFavorite(item: gif)
        }
    }
}
