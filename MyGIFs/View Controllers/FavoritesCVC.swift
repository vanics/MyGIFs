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
import RxSwift
import RxCocoa
import RxDataSources

fileprivate enum Identifiers {
    static let FavoriteCVCell = "FavoriteCVCell"
}

class FavoritesCVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, FluidLayoutDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fluidCollectionViewLayout: FluidCollectionViewLayout!
    
    // Allow quite some memory, but is either memory or CPU
    // https://github.com/kirualex/SwiftyGif#benchmark
    let gifManager = SwiftyGifManager(memoryLimit: GIF.memoryLimitInFavorites)
    let gifLevelOfIntegrity = GIF.levelOfIntegrityInFavorites
    
    private var viewModel: FavoritesViewModel!
    private let disposeBag = DisposeBag()

    private var noItemsView = NoItemsView()

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = FavoritesViewModel()
        
        collectionView.dataSource = nil // RxSwift will take care of that
        collectionView.delegate = nil
        collectionView.alwaysBounceVertical = true

        fluidCollectionViewLayout.delegate = self
        //collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        
        noItemsView.textMessage = "You haven't added any favorite GIF yet."

        // Register cell classes
        collectionView!.register(UINib(nibName: Identifiers.FavoriteCVCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.FavoriteCVCell)
        
        collectionView.register(FavoriteSuplementaryView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "test")
        

        rxSetupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.loadData()
    }

    // MARK: - RxSwift Binding
    
    private func rxSetupBindings() {
        // MARK: - Data Source
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<FavoritesViewModel.Section>(configureCell: {
            (dataSource, cv, indexPath, item) in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: Identifiers.FavoriteCVCell, for: indexPath) as! FavoriteCVCell
            cell.setupCell(delegate: self, viewModel: item, gifLevelOfIntegrity: self.gifLevelOfIntegrity)
            return cell

        }, configureSupplementaryView: { (ds, cv, kind, ip) in
            let section = cv.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "test", for: ip) as! FavoriteSuplementaryView
            return section
            //return FavoriteSuplementaryView()
        })
        
        viewModel.items.asObservable()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
//        viewModel.items.asObservable()
//            .bind(to: collectionView.rx.items(cellIdentifier: Identifiers.FavoriteCVCell, cellType: FavoriteCVCell.self)) { row, data, cell in
//                cell.setupCell(delegate: self, viewModel: data, gifLevelOfIntegrity: self.gifLevelOfIntegrity)
//            }
//            .disposed(by: disposeBag)
    }
    
    // MARK: - FluidLayoutDelegate
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {

        let widthForCell = Float(fluidCollectionViewLayout.cellWidth)
        let heightForCell = viewModel.heightForCellAtIndexPath(indexPath, withAvailableWidth: widthForCell)

        return CGFloat(heightForCell)
    }
}

// MARK: - FavoriteActionsDelegate
extension FavoritesCVC: FavoriteActionsDelegate {
    func share(imageData: Data) {
        shareGif(imageData: imageData)
    }
    
    func deleteFavorite(forCell cell: FavoriteCVCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            viewModel.removeItemAt(indexPath)
        }
    }
}
