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

class FavoritesCVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    // Allow quite some memory, but is either memory or CPU
    // https://github.com/kirualex/SwiftyGif#benchmark
    let gifManager = SwiftyGifManager(memoryLimit: 200)
    let levelOfIntegrity = 0.5
    
    // TODO: Manage it better in the VC Life Cycle
    
    private var gifs: [LocalGif] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        self.collectionView!.register(UINib(nibName: Identifiers.FavoriteCVCell, bundle: nil), forCellWithReuseIdentifier: Identifiers.FavoriteCVCell)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext = appDelegate.persistentContainer.viewContext

        let fetchRequest =
            NSFetchRequest<LocalGif>(entityName: "LocalGif")
        
        do {
            gifs = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gifs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifiers.FavoriteCVCell, for: indexPath) as! FavoriteCVCell
        
        // Configure the cell
        cell.localGif = gifs[indexPath.row]
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let localGif = gifs[indexPath.row]
        
        // Hardcoded for now
        let predefinedCellBorder: CGFloat = 10
        
        let numberOfCellPerRow: CGFloat = 2
        let widthForCell = (collectionView.bounds.size.width / numberOfCellPerRow) - predefinedCellBorder
        
        let heightForCell = Calculation.heightForWidth(widthForCell, originalWidth: localGif.localImageWidth, originalHeight: localGif.localImageHeight)

        return CGSize(width: widthForCell+predefinedCellBorder, height: heightForCell+predefinedCellBorder)
    }

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension FavoritesCVC: FavoriteActionsDelegate {
    func deleteFavorite(_ object: LocalGif) {
        MyGifsCoreData.shared.deleteByObject(object)
    }
}
