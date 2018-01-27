//
//  FavoritesCVC.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 24/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit
import CoreData
import SwiftyGif

fileprivate enum Identifiers {
    static let FavoriteCVCell = "FavoriteCVCell"
}

class FavoritesCVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FluidLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Allow quite some memory, but is either memory or CPU
    // https://github.com/kirualex/SwiftyGif#benchmark
    let gifManager = SwiftyGifManager(memoryLimit: 200)
    let levelOfIntegrity = 0.5
    
    var noItemsView = NoItemsView()
    
    // TODO: Manage it better in the VC Life Cycle
    
    private var gifs: [LocalGif] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self

        noItemsView.textMessage = "You haven't added any favorite GIF yet."
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        self.collectionView!.register(UINib(nibName: Identifiers.FavoriteCVCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.FavoriteCVCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        gifs = MyGifsCoreData.shared.fetchAll()
        collectionView.reloadData()
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numOfGifs = gifs.count
        
        if numOfGifs > 0 {
            collectionView.backgroundView = nil
        } else {
            collectionView.backgroundView = noItemsView
        }
        
        return numOfGifs
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.FavoriteCVCell, for: indexPath) as! FavoriteCVCell
        
        // Configure the cell
        cell.favoriteActionsDelegate = self
        cell.localGif = gifs[indexPath.row]
        
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let localGif = gifs[indexPath.row]
        
        // Hardcoded for now
        let predefinedCellBorder: CGFloat = 0
        let numberOfCellPerRow: CGFloat = 2
        
        let widthForCell = (collectionView.bounds.size.width / numberOfCellPerRow)
        let widthForImage = widthForCell - (predefinedCellBorder * 2) // Both sides
        
        let heightForImage = Calculation.heightForWidth(widthForImage, originalWidth: localGif.localImageWidth, originalHeight: localGif.localImageHeight)

        let heightForCell = heightForImage + (predefinedCellBorder * 2) // Both sides
        
        return CGSize(width: widthForCell, height: heightForCell)
    }
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let localGif = gifs[indexPath.row]
        
        // Hardcoded for now
        let predefinedCellBorder: CGFloat = 0
        let numberOfCellPerRow: CGFloat = 2
        
        let widthForCell = (collectionView.bounds.size.width / numberOfCellPerRow)
        let widthForImage = widthForCell - (predefinedCellBorder * 2) // Both sides
        
        let heightForImage = Calculation.heightForWidth(widthForImage, originalWidth: localGif.localImageWidth, originalHeight: localGif.localImageHeight)
        
        let heightForCell = heightForImage + (predefinedCellBorder * 2) // Both sides

        
        return heightForCell

    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsetsMake(0, 0, 0, 0)
//    }
    
    // MARK: - UICollectionViewDelegate

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}

extension FavoritesCVC: FavoriteActionsDelegate {
    func deleteFavorite(forCell cell: FavoriteCVCell) {
        guard let object = cell.localGif,
            let localImageFileName = object.localImageFileName,
            let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        if MyGifsCoreData.shared.deleteByObject(object) {
            _ = PersistGif.shared.removeImage(fileName: "\(localImageFileName)")
        }
        
        gifs.remove(at: indexPath.row)
        
        collectionView.performBatchUpdates({
            collectionView.deleteItems(at: [indexPath])
        })
    }
}
