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
    var id: String
    var width: Float
    var height: Float
    var isFavorite = Variable(false)
}
