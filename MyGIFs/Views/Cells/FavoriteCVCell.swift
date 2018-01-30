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
    func share(imageData: Data)
}

class FavoriteCVCell: UICollectionViewCell {
    @IBOutlet private weak var gifImageView: UIImageView!
    @IBOutlet private weak var favoriteBtn: UIButton!
    @IBOutlet private weak var shareBtn: UIButton!
    
    // MARK: - Attributes
    private var gifLevelOfIntegrity: Float = 1.0
    
    private weak var favoriteActionsDelegate: FavoriteActionsDelegate?

    // MARK: - Public Interface
    func setupCell(delegate: FavoriteActionsDelegate, viewModel: FavoriteCellViewModel, gifLevelOfIntegrity: Float) {
        self.favoriteActionsDelegate = delegate
        self.gifLevelOfIntegrity = gifLevelOfIntegrity
        self.viewModel = viewModel
    }
    
    // MARK: - Cell Setup
    private var viewModel: FavoriteCellViewModel? {
        didSet {
            guard let viewModel = viewModel,
                let imageData = viewModel.imageData,
                let gifManager = favoriteActionsDelegate?.gifManager else {
                return
            }
            
            let gif = UIImage(gifData: imageData, levelOfIntegrity: gifLevelOfIntegrity)
            gifImageView.setGifImage(gif, manager: gifManager)
        }
    }
    
    // MARK: - Cell Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setupButtons()
    }
    
    override func prepareForReuse() {
        gifImageView.image = nil
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupButtons()
    }
    
    private func setupButtons() {
        // Image inside buttons and PDF files take some extra work.
        favoriteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 10, 10, 0) // top, left, bottom, right
        shareBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 15, 20, 5)
    }
    
    // MARK: - Actions

    @IBAction private func shareBtnDidTouch(_ sender: UIButton) {
        guard let imageData = viewModel?.imageData else {
            return
        }
        
        favoriteActionsDelegate?.share(imageData: imageData)
    }
    
    @IBAction private func favoriteBtnDidTouch(_ sender: UIButton) {
        favoriteActionsDelegate?.deleteFavorite(forCell: self)
    }
}
