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
    func share(imageData: Data)
}

class FeedTVCell: UITableViewCell {    
    
    @IBOutlet private weak var gifImageView: UIImageView!
    @IBOutlet private weak var favoriteBtn: UIButton!
    
    var disposeBag = DisposeBag()
    
    // MARK: - Public Interface
    func setupCell(delegate: FeedActionsDelegate, viewModel: FeedCellViewModel) {
        self.feedActionsDelegate = delegate
        self.viewModel = viewModel
    }
    
    // MARK: - Attributes
    private weak var feedActionsDelegate: FeedActionsDelegate?

    private var viewModel: FeedCellViewModel? {
        didSet {
            guard let viewModel = viewModel else {
                return
            }
            
            backgroundColor = UIColor.randomFlat
            gifImageView?.kf.setImage(with: URL(string: viewModel.imageUrl))
            bindFavoriteBtn(viewModel.isFavorite)
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
    
    private func bindFavoriteBtn(_ isFavorite: Variable<Bool>) {
        guard let viewModel = viewModel else { return }

        isFavorite.asObservable()
            .subscribe(onNext: { [weak self] isFavorite in
                let imageName = (isFavorite) ? "FavoritesFillIcon" : "FavoritesIcon"
                self?.favoriteBtn.setImage(UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
                self?.favoriteBtn.imageView?.tintColor = .red

            })
            .disposed(by: disposeBag)
        
        favoriteBtn.rx.tap
            .bind {
                if let imageData = self.gifImageView.kf.base.image?.kf.gifRepresentation() {
                    viewModel.favoriteImage(imageData: imageData)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions

    // Doesn't make sense not to use delegate here. We need the imageData
    // and the imageData should be sent to the viewController for the share
    // functionality. So, use FeedActionsDelegate.
    
    // We can also bind the button action using RxSwift as it was done with
    // the favoriteBtn

    @IBAction private func shareBtnDidTouch(_ sender: UIButton) {
        guard let imageData = gifImageView.kf.base.image?.kf.gifRepresentation() else {
            return
        }
        
        feedActionsDelegate?.share(imageData: imageData)
    }
}
