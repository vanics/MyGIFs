//
//  FeedTVCell.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit
import Kingfisher
import RxSwift

protocol FeedActionsDelegate: class {
    func addFavorite(item: Gif, imageData: Data)
    func removeFavorite(item: Gif)
    func share(imageData: Data)
}

class FeedTVCell: UITableViewCell {    
    
    @IBOutlet private weak var gifImageView: UIImageView!
    @IBOutlet private weak var favoriteBtn: UIButton!
    
    private var isFavorite: Bool! // TODO: Remove it.

    var disposeBag = DisposeBag()
    
    // MARK: - Public Interface
    func setupCell(delegate: FeedActionsDelegate, gif: Gif) {
        self.feedActionsDelegate = delegate
        self.gif = gif
    }
    
    // MARK: - Attributes
    private weak var feedActionsDelegate: FeedActionsDelegate?

    private var gif: Gif? {
        didSet {
            backgroundColor = UIColor.randomFlat

            if let imageUrl = gif?.fixedWidth?.url {
                gifImageView?.kf.setImage(with: URL(string: imageUrl))
                isFavorite = gif?.isSaved()
                setFavoriteBtn(isFavorite)
            }
        }
    }
    
    // MARK: - Cell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancelImageDownloadTask()
        disposeBag = DisposeBag()
    }
    
    // MARK: - Helpers

    private func cancelImageDownloadTask() {
        gifImageView?.kf.cancelDownloadTask()
        
        // TODO: Check if it really clears the previous image
        gifImageView?.image = nil
    }
    
    private func setFavoriteBtn(_ isFavorite: Bool) {
        let imageName = (isFavorite) ? "FavoritesFillIcon" : "FavoritesIcon"
        favoriteBtn.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteBtn.imageView?.tintColor = .red
    }
    
    // MARK: - Actions
    @IBAction private func shareBtnDidTouch(_ sender: UIButton) {
        guard let imageData = gifImageView.kf.base.image?.kf.gifRepresentation() else {
            return
        }
        
        feedActionsDelegate?.share(imageData: imageData)
    }
    
    @IBAction private func favoriteBtnDidTouch(_ sender: UIButton) {

        // TODO: Check if the image was loaded
        guard let gif = gif,
            let imageData = gifImageView.kf.base.image?.kf.gifRepresentation() else {
            return
        }

        // TODO: Should retrieve that staticaly but model should be updated first
        // For now, let's check on the Core Data again.
        
        setFavoriteBtn(!isFavorite)
        
        if !isFavorite {
            feedActionsDelegate?.addFavorite(item: gif, imageData: imageData)
        } else {
            feedActionsDelegate?.removeFavorite(item: gif)
        }
        
        isFavorite = !isFavorite
    }
}
