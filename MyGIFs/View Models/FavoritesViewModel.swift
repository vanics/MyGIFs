//
//  FavoritesVM.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class FavoritesViewModel {
    typealias Section = AnimatableSectionModel<Int, FavoriteCellViewModel>

    let items: Observable<[Section]>
    private let itemsVariable = Variable<[FavoriteCellViewModel]>([])
//    private let disposeBag = DisposeBag()

    init () {
        items = itemsVariable.asObservable().map { [Section(model: 0, items: $0)] }

//        itemsVariable.asObservable()
//            .map { Section(model: 0, items: $0) }
//            .subscribe(onNext: { [weak self] item in
//                self?.items.value = [item]
//            })
//        .disposed(by: disposeBag)
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
