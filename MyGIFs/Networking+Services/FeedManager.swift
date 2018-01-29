//
//  FeedManager.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 26/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import ObjectMapper
import RxSwift

enum FeedManagerType {
    case search, feed
}

class FeedManager {
    
    typealias Completion = ((_ updated: Bool, _ partialUpdated: Int?, _ error: String?) -> Void)

    private let disposeBag = DisposeBag()

    private(set) var totalItem = 0
    private(set) var currentOffset = 0
    private(set) static var limit = 30
    private(set) var isLoading = false

    // MARK: - Attributes
//    var query: String = "" {
//        didSet {
//            if oldValue != query {
//                cleanTracking()
//            }
//        }
//    }
    
    var query = Variable<String>("")
    
    private(set) var gifs = Variable<[Gif]>([])

    init() {
        // Setup Query Reactivity
        query.asObservable()
            .distinctUntilChanged()
            .throttle(0.2, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] text in
                self.cleanTracking()
                self.retrieveSearch(onCompletion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Interface
    
    func retrieveGifs(onCompletion: Completion?) {
        guard !isLoading else {
            return
        }
        
        // TODO: Run in Serial thread

        if query.value.isEmpty {
            retrieveFeed(onCompletion: onCompletion)
        } else {
            retrieveSearch(onCompletion: onCompletion)
        }
        
        isLoading = true
    }
    
    func cleanTracking() {
        totalItem = 0
        currentOffset = 0

        gifs.value = []
    }
    
    // MARK: - Private Interface
    
    private func retrieveSearch(onCompletion: Completion?) {
        GiphyProvider.rx.request(
            .search(value: query.value, limit: FeedManager.limit, offset: currentOffset))
            .mapJSON() // .mapArray(Gif.self)
            .subscribe { [weak self] (event) in
                // This is in the main thread
                self?.parseEventReturn(event: event, onCompletion: onCompletion)
            }
            .disposed(by: disposeBag)
    }
    
    private func retrieveFeed(onCompletion: Completion?) {
        GiphyProvider.rx.request(
            .trending(limit: FeedManager.limit, offset: currentOffset))
            .mapJSON()
            .subscribe { [weak self] (event) in
                // This is in the main thread
                self?.parseEventReturn(event: event, onCompletion: onCompletion)
            }
            .disposed(by: disposeBag)
    }
    
    private func parseEventReturn(event: SingleEvent<Any>, onCompletion: Completion?) {

        isLoading = false
        
        switch event {
        case .success(let response):
            if let jsonDict = response as? NSDictionary,
                let jsonData = jsonDict["data"],
                let paginationDict = jsonDict["pagination"] as? NSDictionary,
                let offset = paginationDict["offset"] as? Int,
                let count = paginationDict["count"] as? Int,
                let totalCount = paginationDict["total_count"] as? Int,
                let gifs = Mapper<Gif>().mapArray(JSONObject: jsonData) {
                
                // For some reason the limit wasn't correctly set, use the returned then
                if count != FeedManager.limit {
                    FeedManager.limit = count
                }
                
                totalItem = totalCount
                
                currentOffset = offset + FeedManager.limit
                
                var previousItemsCount: Int?

                if offset != 0 {
                    previousItemsCount = self.gifs.value.count
                }
                
                self.gifs.value.append(contentsOf: gifs)
                
                onCompletion?(true, previousItemsCount, nil)
            } else {
                onCompletion?(false, nil, "Error parsing data")
            }
        case .error(let error):
            onCompletion?(false, nil, error.localizedDescription)
        }
    }
}
