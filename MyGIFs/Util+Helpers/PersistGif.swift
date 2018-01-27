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
    static let shared = PersistGif()
    
    // MARK: - Config
    private let storageFolder = "gifs"
    
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
        
        // Create folder if it doesn't exist
        if storageFolder.count > 0 && !fileManager.fileExists(atPath: storagePath) {
            do {
                try fileManager.createDirectory(atPath: storagePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Couldn't create document directory")
            }
        }
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
    
    // MARK: - Public Interface
    
    func removeImage(fileName: String) -> Bool {
        let filePath = storageURL.appendingPathComponent("\(fileName)")

        if let success = try? removeImage(filePath: filePath) {
            return success
        }
        
        return false
    }
    
    func storeLocalImage(name: String, imageData: Data) -> String? {
        
        let fileName = "\(name).gif"
        let filePath = storageURL.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: filePath, options: .atomic)
            return fileName
        } catch {
            print("couldn't write image")
            // TODO: Treat error (Maybe, not enough space?)
        }
        
        return nil
    }
    
    func imagePath(fileName: String, keepExtension: Bool = true) -> String? {
        
        let fileURL = storageURL.appendingPathComponent("\(fileName)")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if !keepExtension {
                return fileURL.deletingPathExtension().path
            }
            
            return fileURL.path
        }
        
        return nil
    }
    
    func imageData(forFileName fileName: String) -> Data? {
        
        let filePath = storageURL.appendingPathComponent("\(fileName)").path
        
        if FileManager.default.fileExists(atPath: filePath) {
            return FileManager.default.contents(atPath: filePath)
        }
        
        return nil
    }
}
