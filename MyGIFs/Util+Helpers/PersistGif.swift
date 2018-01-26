//
//  PersistGif.swift
//  MyGIFs
//
//  Created by Ícaro Oliveira on 26/01/18.
//  Copyright © 2018 vanics. All rights reserved.
//

import UIKit

class PersistGif {
    
    // Singleton
    let shared = PersistGif()
    
    private let storageFolder = GIF.storageFolder
    
    // Get access to shared instance of the file manager
    private let fileManager = FileManager.default
    
    private var documentsURL: URL
    
    private var storageURL: URL
    
    private var storagePath: String
    
    private init() {
        // Get the URL for the users home directory
        documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        storageURL = documentsURL.appendingPathComponent(storageFolder)
        
        // Get the document URL as a string
        storagePath = storageURL.path
    }
    
    func removeImage(name: String) -> Bool {
        // Create filePath URL by appending final path component (name of image)
        let filePath = documentsURL.appendingPathComponent("\(name).gif")

        if let success = try? removeImage(filePath: filePath) {
            return success
        }
        
        return false
    }
    
    private func removeImage(filePath: URL) throws -> Bool {
        // Look through array of files in documentDirectory
        let files = try fileManager.contentsOfDirectory(atPath: "\(storagePath)")
        
        for file in files {
            // If we find existing image filePath, delete it a
            if "\(storageURL.path)/\(file)" == filePath.path {
                try fileManager.removeItem(atPath: filePath.path)
                return true
            }
        }
        
        return false
    }
    
    func storeLocalImage(name: String, imageData: Data) -> Bool {
        
        // Create filePath URL by appending final path component (name of image)
        let filePath = documentsURL.appendingPathComponent("\(name).gif")
        
        do {
            try imageData.write(to: filePath, options: .atomic)
            return true
        } catch {
            print("couldn't write image")
            // TODO: Treat error (Maybe, not enough space?)
        }
        
        return false
    }
}
