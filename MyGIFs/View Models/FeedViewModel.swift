//
//  FeedViewModel.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class FeedViewModel {
    let isLoading: Driver<Bool>
    let isEmpty: Driver<Bool>
    
    var items: Observable<[Gif]>
    
    private let isLoadingVariable = Variable(false)
    private let isEmptyVariable = Variable(false)

    private var feedManager: FeedManager
    private let disposeBag = DisposeBag()

    typealias Completion = ((_ updated: Bool, _ partialUpdated: Int?, _ error: String?) -> Void)

    private var largeGifSelectionIndexPath: IndexPath?
    private let defaultHeight: Float = 150
    
    var searchQuery = Variable<String>("")

    
    init() {
        // Initialize with Model if Any, in this case load Feed Manager
        feedManager = FeedManager()
        
        // Reinforce private scope for mutability
        items = feedManager.gifs.asObservable()
        
        isLoading = isLoadingVariable.asDriver()
        isEmpty = isEmptyVariable.asDriver()
        
        searchQuery.asObservable()
            .bind(to: feedManager.query)
            .disposed(by: disposeBag)
    }
    
    func retrieveData(onCompletion: Completion?) {
        isLoadingVariable.value = true
        feedManager.retrieveGifs { [weak self] (updated, previousItemsCount, error) in
            onCompletion?(updated, previousItemsCount, error)
//            let viewModels = people.map(PersonViewModelImp.init(person:))
//            items.value += viewModels
            self?.isLoadingVariable.value = false
        }
    }
    
    func heightForRowAtIndexPath(_ indexPath: IndexPath, withAvailableWidth availableWidth: Float) -> Float {
        let gif = feedManager.gifs.value[indexPath.row]
        
        if indexPath == largeGifSelectionIndexPath,
            let originalWidth = gif.fixedWidth?.width,
            let originalHeight = gif.fixedWidth?.height {
            
            let height = computeCellHeightForWidth(availableWidth, originalWidth: originalWidth, originalHeight: originalHeight)
            
            return height
        } else {
            return defaultHeight
        }
    }
    
    private func computeCellHeightForWidth(_ targetWidth: Float, originalWidth: Float, originalHeight: Float) -> Float {
        return Calculation.heightForWidth(
            targetWidth,
            originalWidth: originalWidth,
            originalHeight: originalHeight
        )
    }

    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return feedManager.gifs.value.count
    }
    
    func cellForIndexPath(_ indexPath: IndexPath) -> Gif {
        return feedManager.gifs.value[indexPath.row]
    }
    
    var indexPathsForUpdate = [IndexPath]()

    func selectRowAtIndexPath(_ indexPath: IndexPath) {
        indexPathsForUpdate = [indexPath]
        
        if let oldSelectedIndexPath = largeGifSelectionIndexPath,
            indexPath != oldSelectedIndexPath {
            indexPathsForUpdate.append(oldSelectedIndexPath)
        }
        
        // It's the same as the previous which means we should unselect it.
        if indexPath == largeGifSelectionIndexPath {
            largeGifSelectionIndexPath = nil
        } else {
            largeGifSelectionIndexPath = indexPath
        }
    }
}
