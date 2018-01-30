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
    
    private var feedManager: FeedManager
    private let disposeBag = DisposeBag()

    private var largeGifSelectionIndexPath: IndexPath?
    private let defaultHeight: Float = 150
    
    private var isFirstTimeViewAppear = true
    
    // MARK: - Attributes / Output
    
    /// showLoading is true always when the data source (items) was
    /// cleared up and the Loading Indicator should be presented
    let showLoading: Observable<Bool>
    
    let isEmpty: Observable<Bool>
    let onError: Observable<String>
    let items: Observable<[FeedCellViewModel]>

    let modelItems = Variable<[FeedCellViewModel]>([])
    
    /// Setting Search Query will also trigger data loading
    var searchQuery = Variable<String>("")

    init() {
        // Initialize with Model if Any, in this case load Feed Manager
        feedManager = FeedManager()
        
        // Let's add some glue connecting the Feed Manager. ;)
        showLoading = feedManager.showLoading.asObservable()
        isEmpty = feedManager.isEmpty.asObservable()
        onError = feedManager.error
        
        feedManager.gifs.asObservable()
            .map { $0.map(FeedCellViewModel.init(model:))}
            .bind(to: modelItems)
            .disposed(by: disposeBag)
        
        items = modelItems.asObservable()
        
        // TODO: Binding will also send the value triggering an unnecessary
        // retrieve, fix this later
        searchQuery.asObservable()
            .bind(to: feedManager.query)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Interface
    
    func retrieveFeed() {
        feedManager.retrieveGifs()
    }
    
    func viewWillAppear() {
        guard !isFirstTimeViewAppear else {
            isFirstTimeViewAppear = false
            return
        }
        
        // Synchronize data from CoreData since it might
        // changed on other screens
        for item in modelItems.value {
            item.syncData()
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
    
    // MARK: - Private
    
    private func computeCellHeightForWidth(_ targetWidth: Float, originalWidth: Float, originalHeight: Float) -> Float {
        return Calculation.heightForWidth(
            targetWidth,
            originalWidth: originalWidth,
            originalHeight: originalHeight
        )
    }
}
