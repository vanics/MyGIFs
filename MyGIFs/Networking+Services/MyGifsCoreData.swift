//
//  MyGifsCoreData.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 25/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit // For UIApplication
import CoreData

enum CoreDataError: String {
    case managedContextNotLoaded = "Managed Context not initialized in App Delegate"
}

// Could also have created an LocalGif extension
class MyGifsCoreData {
    static let shared = MyGifsCoreData()
    static let entityName = "LocalGif"
    
    private let persistentContainer: NSPersistentContainer!

    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    private init () {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Cannot get shared APP delegate")
        }
        persistentContainer = appDelegate.persistentContainer
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true

    }
    
    // MARK: Public Interface
    
    func retrieveById(_ id: String) -> Bool {
        
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
    
    func fetchAll() -> [LocalGif] {
        do {
            return try managedContext.fetch(LocalGif.fetchRequest())

        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return []
    }
    
    func insertItem(_ item: Gif, imagePath: String) {
        
        // TODO: Run it async

        guard let newGif = NSEntityDescription.insertNewObject(forEntityName: MyGifsCoreData.entityName, into: backgroundContext) as? LocalGif else {
            return
        }
        
        newGif.id = item.id
        newGif.title = item.title
        newGif.bitlyGifUrl = item.bitlyGifUrl
        newGif.bitlyUrl = item.bitlyUrl
        newGif.caption = item.caption
        newGif.localImageFileName = imagePath
        newGif.localImageHeight = item.fixedWidth!.height ?? 0.0
        newGif.localImageSize = item.fixedWidth!.size ?? 0.0
        newGif.localImageWidth = item.fixedWidth!.width ?? 0.0
        newGif.username = item.username
        
        do {
            try backgroundContext.save()
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteById(_ id: String) -> Bool {
        
        let request = NSFetchRequest<LocalGif>(entityName: MyGifsCoreData.entityName)
        let predicate = NSPredicate(format: "id == %@", id)
        request.predicate = predicate
        
        if let result = try? backgroundContext.fetch(request) {
            var deletes = 0

            for object in result {
                backgroundContext.delete(object)
                try? backgroundContext.save()
                deletes += 1
            }
            
            if deletes > 0 {
                return true
            }
        }
        
        return false
    }
    
    func deleteByObject(_ object: LocalGif) -> Bool {
        managedContext.delete(object)
        try? managedContext.save()
        
        return true
    }
    
    func saveContext() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                print("Save error \(error)")
            }
        }
    }
}
