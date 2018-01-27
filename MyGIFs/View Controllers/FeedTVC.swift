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
import ObjectMapper
import Kingfisher

fileprivate enum Identifiers {
    static let FeedTVCell = "FeedTVCell"
}

class FeedTVC: UITableViewController {

    // By defining nil we say that we want to use the same view that we're
    // searching to display the results
    let searchController = UISearchController(searchResultsController: nil)

    static let minimumDistanceToTriggerFeedManagerLoad: CGFloat = 1000

    lazy var feedManager = FeedManager()
    
    let disposeBag = DisposeBag()
    private var largeGifSelectionIndexPath: IndexPath?
    
    let temporaryCDContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // MARK: - Some UI Setup
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        loading.hidesWhenStopped = true
        loading.tintColor = UIColor.white
        return loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImageCaching()
        setupSearchController()
        
        tableView.backgroundView = loadingIndicator
        loadDynamicData()
    }
    
    // MARK: - Feed Manager
    
    func loadDynamicData() {
        loadingIndicator.startAnimating()

        feedManager.retrieveGifs { [weak self] (updated, previousItemsCount, error) in
            self?.loadingIndicator.stopAnimating()
            
            if let error = error {
                self?.showAlert(title: "Error", message: error)
                return
            }
            
            if updated {
                self?.updateTableView(currentItemsCount: self!.feedManager.gifs.count, previousItemCount: previousItemsCount)
            }
        }
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedManager.gifs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.FeedTVCell, for: indexPath) as! FeedTVCell
        
        // Configure the cell...
        cell.feedActionsDelegate = self
        cell.gif = feedManager.gifs[indexPath.row]

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPathsForUpdate = [indexPath]
        
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
        
        updateRowAt(indexPaths: indexPathsForUpdate)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == largeGifSelectionIndexPath,
            let height = feedManager.gifs[indexPath.row].fixedWidth?.heightForWidth(view.frame.width) {
            return height
        } else {
            return 150
        }
    }
    
    // MARK: - Image Caching and Related
    
    func setupImageCaching() {
        ImageCache.default.maxDiskCacheSize = 100 * 1024 * 1024 // 50 MB
        // Default cache stores it for up to one week
    }
    
    // MARK: - UIScrollView / Infinite Scrolling
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentContentOffset = scrollView.contentOffset.y
        let maximumContentOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        let distanceFromBottom = maximumContentOffset - currentContentOffset
        
        // Set the minimum distance from bottom to load more posts
        if distanceFromBottom <= FeedTVC.minimumDistanceToTriggerFeedManagerLoad {
            loadDynamicData()
        }
    }
    
    // MARK: - Release Keyboard if user interact with scrollView
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
    
    // MARK: - Add items without reloading the tableView (More fluid experience)
    func updateTableView(currentItemsCount: Int, previousItemCount: Int?) {
        
        guard let previousItemCount = previousItemCount, currentItemsCount > previousItemCount else {
            tableView.reloadData()
            return
        }
        
        var indexPaths = [IndexPath]()

        for nextIndex in previousItemCount..<currentItemsCount {
            indexPaths.append(IndexPath(row: nextIndex, section: 0))
        }
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .automatic)
        tableView.endUpdates()
    }
    
    // MARK: - Util
    func updateRowAt(indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPaths, with: UITableViewRowAnimation.middle)
        tableView.endUpdates()
    }
}

extension FeedTVC: FeedActionsDelegate {
    func addFavorite(item: Gif, imageData: Data) {
        if let imagePath = PersistGif.shared.storeLocalImage(name: item.id, imageData: imageData) {
            MyGifsCoreData.shared.saveNewItem(item, imagePath: imagePath)
        }
    }
    
    func removeFavorite(item: Gif) {
        // TODO: Invert it
        if MyGifsCoreData.shared.deleteById(item.id) {
            _ = PersistGif.shared.removeImage(fileName: "\(item.id).gif")
        }
    }
}

extension FeedTVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        feedManager.query = searchController.searchBar.text ?? ""
        tableView.reloadData() // DataSource Changed due query change
        loadDynamicData() // LoadData for new query || Will be RxSwift like later
    }
    
    // MARK: - Private
    
    // Setup the Search Controller
    private func setupSearchController() {
        //navigationController?.hidesBarsOnSwipe = true
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search GIFs"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.tintColor = .white

        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true // By Default
        
        // We can't do it with Interface Builder
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            tableView.tableHeaderView = searchController.searchBar
            
            // TODO: Improve Search Controller in iOS 10
        }
        
        // Ensure that the search bar does not remain on screen if the user
        // navigates to another view controller while the UISearchController is active
        definesPresentationContext = true
    }
}
