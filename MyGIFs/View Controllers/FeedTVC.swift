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
    var gifs = [Gif]()
    let disposeBag = DisposeBag()
    private var largeGifSelectionIndexPath: IndexPath?
    
    let temporaryCDContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var indexOfCurrentContentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImageCaching()
        setupSearchController()
        
        // .mapArray(Gif.self)
        GiphyProvider.rx.request(
            .trending(limit: nil, offset: nil))
            .mapJSON()
            .subscribe { [weak self] (event) in
                // This is in the main thread
                switch event {
                // TODO: When to use NSDictionary
                case .success(let response):
                    if let jsonDict = response as? NSDictionary,
                       let jsonData = jsonDict["data"],
                       let gifs = Mapper<Gif>().mapArray(JSONObject: jsonData) {
                        self?.gifs = gifs
                        self?.tableView.reloadData()
                    } else {
                        self?.showAlert(title: "Error", message: "Error parsing data")
                    }
                case .error(let error):
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                    break
                }
            }
        .disposed(by: disposeBag)
        
        /*
        Network.request(.trending(limit: 20, offset: 10), success: { (response) in
            print(response)
        }, error: { (response) in
            print(response)

        }) { (moyaError) in
            print(moyaError)
        }
         */
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gifs.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.FeedTVCell, for: indexPath) as! FeedTVCell
        
        // Configure the cell...
        cell.feedActionsDelegate = self
        cell.gif = gifs[indexPath.row]

        return cell
    }
    
    func coreData() {
        
    }
    
    // MARK: - Image Caching and Related
    
    func setupImageCaching() {
        ImageCache.default.maxDiskCacheSize = 50 * 1024 * 1024 // 50 MB
        // Default cache stores it for up to one week
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPathsForUpdate = [indexPath]
        
        if let oldSelectedIndexPath = largeGifSelectionIndexPath,
            indexPath != oldSelectedIndexPath {
            indexPathsForUpdate.append(oldSelectedIndexPath)
        }
        
        largeGifSelectionIndexPath = indexPath
        
        tableView.beginUpdates()
        tableView.reloadRows(at: indexPathsForUpdate, with: UITableViewRowAnimation.fade)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == largeGifSelectionIndexPath,
            let height = gifs[indexPath.row].fixedWidth?.heightForWidth(view.frame.width) {
            return height
        } else {
            return 150
        }
    }
    
    // We want to avoid loading an image in the wrong cell
    // without this, it could happen if the user scrolls too fast
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.FeedTVCell) as? FeedTVCell
        cell?.cancelImageDownloadTask()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: - UIScrollView / Infinite Scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Where the user is in the y-axis
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let contentRemainder = contentHeight - scrollView.frame.size.height
        
        if offsetY > contentRemainder {
            indexOfCurrentContentPage += 1
            
            // Load more data
        }
    }
}

extension FeedTVC: FeedActionsDelegate {
    func addFavorite(item: Gif, imageData: Data) {
        MyGifsCoreData.shared.saveNewItem(item, imageData: imageData)
    }
    
    func removeFavorite(item: Gif) {
        
    }
}

extension FeedTVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
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
        }
        
        // Ensure that the search bar does not remain on screen if the user
        // navigates to another view controller while the UISearchController is active
        definesPresentationContext = true
    }
}
