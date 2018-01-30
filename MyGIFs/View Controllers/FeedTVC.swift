//
//  FeedTVC.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
//import RxDataSources
import ObjectMapper
import Kingfisher

fileprivate enum Identifiers {
    static let FeedTVCell = "FeedTVCell"
}

class FeedTVC: UITableViewController {

    // By defining nil we say that we want to use the same view that we're
    // searching to display the results
    private let searchController = UISearchController(searchResultsController: nil)
    private let disposeBag = DisposeBag()
    
    // MARK: - Config
    static let minimumDistanceToTriggerFeedManagerLoad: CGFloat = 1000

    // TODO: Inject it on the init
    lazy var viewModel: FeedViewModel = FeedViewModel()
    
    // MARK: - Some UI Setup

    private lazy var messageView: NoItemsView = {
        let noItems = NoItemsView()
        noItems.textMessage = "No items found for the entered parameter."
        return noItems
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView =  {
        let loading = UIActivityIndicatorView()
        loading.hidesWhenStopped = true
        loading.tintColor = UIColor.white
        return loading
    }()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSearchController()
        
        tableView.backgroundView = loadingIndicator
        tableView.alwaysBounceVertical = true
        
        // Using RxSwift instead
        tableView.dataSource = nil
        tableView.dataSource = nil
        
        rxSetupBindings()
        viewModel.retrieveFeed()
    }
    
    // MARK: - RxSwift Setup
    
    func rxSetupBindings() {

        // MARK: - Data Source
        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: Identifiers.FeedTVCell, cellType: FeedTVCell.self)) { _, model, cell in
            cell.setupCell(delegate: self, gif: model)
            }
            .disposed(by: disposeBag)
        
        // Show Loading
        viewModel.showLoading.asObservable()
            .subscribe(onNext: { [weak self] showLoading in
                if showLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        // Change background view accordingly to the loading status
        viewModel.isEmpty.asObservable()
            .subscribe (onNext: { [weak self] isEmpty in
                if isEmpty {
                    self?.tableView.backgroundView = self!.messageView
                } else {
                    self?.tableView.backgroundView = self!.loadingIndicator
                }
            })
            .disposed(by: disposeBag)

        // Error
        viewModel.onError.asObservable()
            .subscribe(onNext: { [weak self] error in
                self?.showAlert(title: "Error", message: error)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Table View Delegates
    // Could also have used rxSwift instead

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectRowAtIndexPath(indexPath)
        updateRowAt(indexPaths: viewModel.indexPathsForUpdate)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(viewModel.heightForRowAtIndexPath(indexPath, withAvailableWidth: Float(view.frame.width)))
    }

    // MARK: - UIScrollView / Infinite Scrolling
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentContentOffset = scrollView.contentOffset.y
        let maximumContentOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        let distanceFromBottom = maximumContentOffset - currentContentOffset
        
        // Set the minimum distance from bottom to load more posts
        if distanceFromBottom <= FeedTVC.minimumDistanceToTriggerFeedManagerLoad {
            viewModel.retrieveFeed()
        }
    }
    
    // MARK: - Release Keyboard if user interact with scrollView
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: - Util
    func updateRowAt(indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.middle)
        tableView.endUpdates()
    }
}

// MARK: - FeedActionsDelegate
extension FeedTVC: FeedActionsDelegate {
    func addFavorite(item: Gif, imageData: Data) {
        if let imagePath = PersistGif.shared.storeLocalImage(name: item.id, imageData: imageData) {
            MyGifsCoreData.shared.insertItem(item, imagePath: imagePath)
        }
    }
    
    func share(imageData: Data) {
        shareGif(imageData: imageData)
    }
    
    func removeFavorite(item: Gif) {
        // TODO: Invert it
        if MyGifsCoreData.shared.deleteById(item.id) {
            _ = PersistGif.shared.removeImage(fileName: "\(item.id).gif")
        }
    }
}

// MARK: - UISearchResultsUpdating
extension FeedTVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    
    // Another option would be have used RxCocoa to bind the search bar
    // instead of using the UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchQuery.value = searchController.searchBar.text ?? ""
    }
    
    // MARK: - Setup Search Controller
    
    // Setup the Search Controller
    private func setupSearchController() {
        //navigationController?.hidesBarsOnSwipe = true
        searchController.searchResultsUpdater = self // we will not use the UISearchResultsUpdating
        searchController.searchBar.placeholder = "Search GIFs"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.tintColor = .white

        searchController.obscuresBackgroundDuringPresentation = false
        
        // We can't do it with Interface Builder
        if #available(iOS 11.0, *) {
            searchController.hidesNavigationBarDuringPresentation = true // By Default
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // TODO: Improve Search Bar in iOS 10

            searchController.searchBar.searchBarStyle = .minimal
            
            // Include the search bar within the navigation bar.
            //tableView.tableHeaderView = searchController.searchBar
            searchController.hidesNavigationBarDuringPresentation = false
            navigationItem.titleView = self.searchController.searchBar
            definesPresentationContext = false
        }
        
        // Ensure that the search bar does not remain on screen if the user
        // navigates to another view controller while the UISearchController is active
        definesPresentationContext = true
    }
}
