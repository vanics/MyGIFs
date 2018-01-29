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
    @IBOutlet weak var fluidCollectionViewLayout: FluidCollectionViewLayout!
    
    // Allow quite some memory, but is either memory or CPU
    // https://github.com/kirualex/SwiftyGif#benchmark
    let gifManager = SwiftyGifManager(memoryLimit: GIF.memoryLimitInFavorites)
    let gifLevelOfIntegrity = GIF.levelOfIntegrityInFavorites
    
    private var noItemsView = NoItemsView()
    
    private var viewModel: FavoritesViewModel!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = FavoritesViewModel()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        fluidCollectionViewLayout.delegate = self
                
        noItemsView.textMessage = "You haven't added any favorite GIF yet."

        collectionView.alwaysBounceVertical = true
        
        // Register cell classes
        self.collectionView!.register(UINib(nibName: Identifiers.FavoriteCVCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.FavoriteCVCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadData()
        collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numOfGifs = viewModel.numberOfRowsInSection(section)
        
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
        cell.setupCell(delegate: self, localGif: viewModel.cellForIndexPath(indexPath), gifLevelOfIntegrity: gifLevelOfIntegrity)
        
        return cell
    }

    // MARK: - FluidLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        
        let widthForCell = Float(fluidCollectionViewLayout.cellWidth)
        let heightForCell = viewModel.heightForCellAtIndexPath(indexPath, withAvailableWidth: widthForCell)
        
        return CGFloat(heightForCell)
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
}

// MARK: - FavoriteActionsDelegate
extension FavoritesCVC: FavoriteActionsDelegate {
    func share(imageData: Data) {
        shareGif(imageData: imageData)
    }
    
    func deleteFavorite(forCell cell: FavoriteCVCell) {
        if let indexPath = collectionView.indexPath(for: cell),
            viewModel.deleteFavorite(forCell: cell, at: indexPath) {
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [indexPath])
            })
        }
    }
}
