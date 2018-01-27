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
    
    private let disposeBag = DisposeBag()

    private var loadingData = false
    private(set) var totalItem = 0
    private(set) var currentOffset = 0
    private(set) static var limit = 30
    private(set) var isLoading = false

    var query: String = "" {
        didSet {
            if oldValue != query {
                cleanTracking()
            }
        }
    }
    
    var gifs = [Gif]()
    
    typealias Completion = ((_ updated: Bool, _ partialUpdated: Int?, _ error: String?) -> Void)

    // TODO: Run in Serial thread to avoid losing part of the data
    
    func retrieveGifs(onCompletion: Completion?) {
        guard !isLoading else {
            return
        }
        
        if query.isEmpty {
            retrieveFeed(onCompletion: onCompletion)
        } else {
            retrieveSearch(onCompletion: onCompletion)
        }
        
        isLoading = true
    }
    
    private func retrieveSearch(onCompletion: Completion?) {
        // .mapArray(Gif.self)
        GiphyProvider.rx.request(
            .search(value: query, limit: FeedManager.limit, offset: currentOffset))
            .mapJSON()
            .subscribe { [weak self] (event) in
                // This is in the main thread
                self?.parseEventReturn(event: event, onCompletion: onCompletion)
            }
            .disposed(by: disposeBag)
    }
    
    private func retrieveFeed(onCompletion: Completion?) {
        // .mapArray(Gif.self)
        GiphyProvider.rx.request(
            .trending(limit: FeedManager.limit, offset: currentOffset))
            .mapJSON()
            .subscribe { [weak self] (event) in
                // This is in the main thread
                self?.parseEventReturn(event: event, onCompletion: onCompletion)
            }
            .disposed(by: disposeBag)
    }
    
    /*
     Network.request(.trending(limit: 20, offset: 10), success: { (response) in
     print(response)
     }, error: { (response) in
     print(response)
     
     }) { (moyaError) in
     print(moyaError)
     }
     */
    
    private func parseEventReturn(event: SingleEvent<Any>, onCompletion: Completion?) {

        isLoading = false
        
        switch event {
        // TODO: When to use NSDictionary
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
                    previousItemsCount = self.gifs.count
                }
                
                self.gifs.append(contentsOf: gifs)
                
                onCompletion?(true, previousItemsCount, nil)
            } else {
                onCompletion?(false, nil, "Error parsing data")
            }
        case .error(let error):
            onCompletion?(false, nil, error.localizedDescription)
        }
    }
    
    func cleanTracking() {
        totalItem = 0
        currentOffset = 0
        loadingData = false
        gifs = []
    }
}
