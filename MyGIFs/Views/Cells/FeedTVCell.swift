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
    
}

class FeedTVCell: UITableViewCell {    
    weak var feedActionsDelegate: FeedActionsDelegate?
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    var gif: Gif? {
        didSet {
            if let imageUrl = gif?.fixedWidth?.url {
                gifImageView?.kf.setImage(with: URL(string: imageUrl))
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.randomFlat
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func cancelImageDownloadTask() {
        gifImageView?.kf.cancelDownloadTask()
    }

}
