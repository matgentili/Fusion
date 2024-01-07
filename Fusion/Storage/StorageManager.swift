//
//  StorageManager.swift
//  Fusion
//
//  Created by Matteo Gentili on 06/01/24.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager2 {
    
    static let shared = StorageManager2()
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    private func itemReference(userId: String, type: ItemType) -> StorageReference {
        return storage.child(type.getPath()).child(userId)
    }
    
    func getPathForItem(item: Item) -> StorageReference {
        Storage.storage().reference(withPath: item.path)
    }
    
    func getUrlForItem(item: Item) async throws -> URL {
        try await getPathForItem(item: item).downloadURL()
    }
    
    func getDataFrom(item: Item) async throws -> Data {
        try await storage.child(item.path).data(maxSize: 30 * 1024 * 1024)
    }
    
    // MARK: Photos
    func saveImage(image: UIImage, item: Item) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        return try await saveImage(data: data, item: item)
    }
    
    func saveImage(data: Data, item: Item) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(item.id).jpeg"
        let returnedMetaData = try await itemReference(userId: item.uidOwner ?? "", type: .photo).child(path).putDataAsync(data, metadata: meta)

        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }

    func getImageFrom(item: Item) async throws -> UIImage {
        let data = try await getDataFrom(item: item)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badServerResponse)
        }
        
        return image
    }
    
    // MARK: Documents
    func saveDocument(data: Data, item: Item) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "application/pdf"
        
        let path = "\(item.id).pdf"
        let returnedMetaData = try await itemReference(userId: item.uidOwner ?? "", type: .document).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }
    
    // MARK: Video
    func saveVideo(data: Data, item: Item) async throws -> (path: String, name: String) {
        let meta = StorageMetadata()
        meta.contentType = "video/mp4"
        
        let path = "\(item.id).mp4"
        let returnedMetaData = try await itemReference(userId: item.uidOwner ?? "", type: .video).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
            throw URLError(.badServerResponse)
        }
        
        return (returnedPath, returnedName)
    }
    
    func deleteItem(item: Item) async throws {
        try await getPathForItem(item: item).delete()
    }
}

/*
 
 final class StorageManager {
     
     static let shared = StorageManager()
     private init() { }
     
     private let storage = Storage.storage().reference()
     
     private var photosReference: StorageReference {
         storage.child("photos")
     }
     
     private func photoReference(userId: String) -> StorageReference {
         return photosReference.child(userId)
         //storage.child("users").child(userId)
     }
     
     func getPathForItem(item: Item) -> StorageReference {
         Storage.storage().reference(withPath: item.path)
     }
     
     func getUrlForItem(item: Item) async throws -> URL {
         try await getPathForItem(item: item).downloadURL()
     }
     
     func getDataFrom(item: Item) async throws -> Data {
         //try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
         try await storage.child(item.path).data(maxSize: 30 * 1024 * 1024)
     }
     
     func getImageFrom(item: Item) async throws -> UIImage {
         let data = try await getDataFrom(item: item)
         
         guard let image = UIImage(data: data) else {
             throw URLError(.badServerResponse)
         }
         
         return image
     }
     
     func saveImage(data: Data, item: Item) async throws -> (path: String, name: String) {
         let meta = StorageMetadata()
         meta.contentType = "image/jpeg"
         
         //let path = "\(UUID().uuidString).jpeg"
         let path = "\(item.id).jpeg"
         let returnedMetaData = try await photoReference(userId: item.id).child(path).putDataAsync(data, metadata: meta)
         
         guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
             throw URLError(.badServerResponse)
         }
         
         return (returnedPath, returnedName)
     }
     
     func saveImage(image: UIImage, item: Item) async throws -> (path: String, name: String) {
         guard let data = image.jpegData(compressionQuality: 0.5) else {
             throw URLError(.backgroundSessionWasDisconnected)
         }
         return try await saveImage(data: data, item: item)
     }
     
     func deleteItem(item: Item) async throws {
         try await getPathForItem(item: item).delete()
     }
 }


 final class StorageManagerDocument {
     
     static let shared = StorageManagerDocument()
     private init() { }
     
     private let storage = Storage.storage().reference()
     
     private var documentsReference: StorageReference {
         storage.child("documents")
     }
     
     private func documentReference(userId: String) -> StorageReference {
         return documentsReference.child(userId)
     }
     
     func getPathForItem(item: Item) -> StorageReference {
         Storage.storage().reference(withPath: item.path)
     }
     
     func getUrlForItem(item: Item) async throws -> URL {
         try await getPathForItem(item: item).downloadURL()
     }
     
     func getDataFrom(item: Item) async throws -> Data {
         //try await userReference(userId: userId).child(path).data(maxSize: 3 * 1024 * 1024)
         try await storage.child(item.path).data(maxSize: 30 * 1024 * 1024)
     }
     
     func saveDocument(data: Data, item: Item) async throws -> (path: String, name: String) {
         let meta = StorageMetadata()
         meta.contentType = "pdf"
         
         //let path = "\(UUID().uuidString).jpeg"
         let path = "\(item.id).pdf"
         let returnedMetaData = try await documentReference(userId: item.id).child(path).putDataAsync(data, metadata: meta)
         
         guard let returnedPath = returnedMetaData.path, let returnedName = returnedMetaData.name else {
             throw URLError(.badServerResponse)
         }
         
         return (returnedPath, returnedName)
     }
     
     func deleteItem(item: Item) async throws {
         try await getPathForItem(item: item).delete()
     }
 }

 */
