//
//  MyGifsCoreData.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import Foundation
import CoreData

class MyGifsCoreData {
    static let shared = MyGifsCoreData()
    
    static let entityName = "LocalGif"
    
    // It will have a context since it will be first called
    var managedContext: NSManagedObjectContext?

    private init () {}
    
    func retrieveById(_ id: String) -> Bool {
        guard let managedContext = managedContext else {
            fatalError("Managed Context not initialized")
        }
        // TODO: Run it async
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: MyGifsCoreData.entityName)
        let predicate = NSPredicate(format: "id == %@", id)
        
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let count = try managedContext.count(for: request)
            
            if count > 0 {
                return true
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        
        return false
    }
    
    private func storeLocalImage(imageData: Data) {
        
    }
    
    func saveNewItem(_ item: Gif, imageData: Data) {
        guard let managedContext = managedContext else {
            fatalError("Managed Context not initialized")
        }
        
        
        // TODO: Run it async
        
//        let entity = NSEntityDescription.entity(forEntityName: MyGifsCoreData.entityName, in: managedContext)
//        let newGif = NSManagedObject(entity: entity!, insertInto: managedContext)
//
        let newGif = LocalGif(context: managedContext)
        newGif.id = item.id
        newGif.title = item.title
        newGif.bitlyGifUrl = item.bitlyGifUrl
        newGif.bitlyUrl = item.bitlyUrl
        newGif.caption = item.caption
        //newGif.localImageFilePath = item
        newGif.localImageHeight = item.fixedWidth!.height ?? 0.0
        newGif.localImageSize = item.fixedWidth!.size ?? 0.0
        newGif.localImageWidth = item.fixedWidth!.width ?? 0.0
        newGif.username = item.username
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func deleteById(_ id: String) -> Bool {
        guard let managedContext = managedContext else {
            fatalError("Managed Context not initialized")
        }
        
        let request = NSFetchRequest<LocalGif>(entityName: "LocalGif")
        let predicate = NSPredicate(format: "id == %@", id)
        request.predicate = predicate
        
        if let result = try? managedContext.fetch(request) {
            var deletes = 0

            for object in result {
                managedContext.delete(object)
                deletes += 1
            }
            
            if deletes > 0 {
                return true
            }
        }
        
        return false
    }
    
    func deleteByObject(_ object: LocalGif) {
        guard let managedContext = managedContext else {
            fatalError("Managed Context not initialized")
        }
        
        managedContext.delete(object)
        try? managedContext.save()
    }
}
