//
//  FavoritesVM.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import RxSwift

class FavoritesViewModel {

    let items: Observable<[FavoriteCellViewModel]>
    
    private let itemsVariable = Variable<[FavoriteCellViewModel]>([])
    
    init () {
        items = itemsVariable.asObservable()
    }
    
    func loadData() {
        itemsVariable.value = MyGifsCoreData.shared.fetchAll()
            .map(FavoriteCellViewModel.init(model:))
    }
    
    func heightForCellAtIndexPath(_ indexPath: IndexPath, withAvailableWidth availableWidth: Float) -> Float {
        let cellViewModel = itemsVariable.value[indexPath.row]
        
        let heightForCell = Calculation.heightForWidth(availableWidth, originalWidth: cellViewModel.width, originalHeight: cellViewModel.height)
        
        return heightForCell
    }
    
    func removeItemAt(_ indexPath: IndexPath) {
        if itemsVariable.value[indexPath.item].deleteFavorite() {
            itemsVariable.value.remove(at: indexPath.item)
        }
    }
}
