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
    
    private var isLoading = false
    private(set) var totalItems = 0
    private(set) var currentOffset = 0
    private(set) static var limit = 30
    private(set) var noMoreItems = false

    // MARK: - Attributes / Output
    private(set) var error = PublishSubject<String>()

    private(set) var showLoading = Variable<Bool>(false)
    private(set) var isEmpty = Variable<Bool>(false)
    
    //private(set) 
    var gifs = Variable<[Gif]>([])

    var query = Variable<String>("")

    // MARK: - Initial Setup
    init() {
        // Setup Query Reactivity ;)
        query.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [unowned self] text in
                self.cleanTracking()
                self.retrieveGifs()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Interface
    
    func retrieveGifs() {
        guard !isLoading && !noMoreItems else {
            return
        }
        
        isLoading = true
        isEmpty.value = false // It's loading. Doesn't define the empty state just yet.
        
        if gifs.value.isEmpty {
            showLoading.value = true
        }
        
        // TODO: Run in Serial thread
        
        if query.value.isEmpty {
            retrieveFeed()
        } else {
            retrieveSearch()
        }
    }
    
    func cleanTracking() {
        totalItems = 0
        currentOffset = 0
        noMoreItems = false
        
        gifs.value = []
    }
    
    // MARK: - Private Interface
    
    private func retrieveSearch() {
        GiphyProvider.rx.request(
            .search(value: query.value, limit: FeedManager.limit, offset: currentOffset))
            .mapJSON() // .mapArray(Gif.self)
            .subscribe { [weak self] (event) in
                // This is in the main thread
                self?.parseEventReturn(event: event)
                self?.isLoading = false
                self?.showLoading.value = false
            }
            .disposed(by: disposeBag)
    }
    
    private func retrieveFeed() {
        GiphyProvider.rx.request(
            .trending(limit: FeedManager.limit, offset: currentOffset))
            .mapJSON()
            .subscribe { [weak self] (event) in
                // This is in the main thread
                self?.parseEventReturn(event: event)
                self?.isLoading = false
                self?.showLoading.value = false
            }
            .disposed(by: disposeBag)
    }
    
    private func parseEventReturn(event: SingleEvent<Any>) {

        switch event {
        case .success(let response):
            if let jsonDict = response as? NSDictionary,
                let jsonData = jsonDict["data"],
                let paginationDict = jsonDict["pagination"] as? NSDictionary,
                let offset = paginationDict["offset"] as? Int,
                let count = paginationDict["count"] as? Int,
                let totalCount = paginationDict["total_count"] as? Int,
                let gifs = Mapper<Gif>().mapArray(JSONObject: jsonData) {
                
                if count < FeedManager.limit {
                    noMoreItems = true
                }
                
                totalItems = totalCount
                currentOffset = offset + FeedManager.limit
                
                self.gifs.value.append(contentsOf: gifs)
                isEmpty.value = gifs.isEmpty // isEmpty by any chance?
                
            } else {
                error.on(.next("Error parsing data"))
                //onCompletion?(false, nil, "Error parsing data")
            }
        case .error(let requestError):
            error.on(.next(requestError.localizedDescription))
        }
    }
}

//fileprivate extension ObserverType {
//    typealias Event = SingleEvent<Any>
//    func mapEventReturn<Event>(transform: @escaping (E) -> Event) -> Observable<Event> {
//        return Observable.create { observer in
//            let subscription = .subscribe { e in
//                switch e {
//                case .next(let value):
//                    let result = transform(value)
//                    observer.on(.next(result))
//                case .error(let error):
//                    observer.on(.error(error))
//                case .completed:
//                    observer.on(.completed)
//                }
//            }
//
//            return subscription
//        }
//    }
//}

