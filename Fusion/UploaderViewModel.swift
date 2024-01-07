//
//  UploaderViewModel.swift
//  Fusion
//
//  Created by Matteo Gentili on 27/12/23.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Combine

@MainActor
class UploaderViewModel: ObservableObject {
    
    @Published var retrievedPhotos: [UIImage] = []
    @Published var itemsPhoto: [Item] = []
    @Published var itemsDocument: [Item] = []
    @Published var itemsVideo: [Item] = []
    @Published var isLoading: Bool = false
    
    var cancellables: Set<AnyCancellable> = []

    let db = Firestore.firestore()
    
    var user: User {
        return Auth.auth().currentUser!
    }
    
    init() {
        Task {
            try? await downloadPhotoItems()
            try? await downloadDocumentItems()
        }
    }
}

// MARK: Metodo in comune
extension UploaderViewModel {
    func updateItem(item: Item, updatedItem: Item) async throws {
        print("Updating item...")
        self.isLoading = true
        try await DataManager.shared.updateItem(item: item, updatedItem: updatedItem)
        self.isLoading = false
        print("😎 Item update completed...")
    }
}

// MARK: Photos
extension UploaderViewModel {
    
    func uploadImage(image: UIImage?) async throws {
        print("Uploading image...")
        self.isLoading = true
        guard let image = image else {
            self.isLoading = false
            return
        }
        
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        // Salvo l'immagine nello storage
        let idItem = UUID().uuidString
        
        // Salvo item in Firestore
        let item = Item(id: idItem,
                        user: user,
                        ext: "jpeg",
                        type: .photo,
                        size: CGFloat(data.count),
                        date: Date().italianDate())
        
        let _ = try await StorageManager2.shared.saveImage(image: image, item: item) // Salvo in Storage

        let _ = try await DataManager.shared.uploadItem(type: .photo, item: item) // Salvo in Firestore

        self.isLoading = false
        
        // Ricarico gli items
        try await downloadPhotoItems()
        print("😎 Image upload completed!")
    }
    
    func downloadPhotoItems() async throws {
        print("Downloading photo items...")
        self.isLoading = true
        self.itemsPhoto = []
        self.itemsPhoto = try await DataManager.shared.getOwnItems(type: .photo)
        self.isLoading = false
        print("😎 Photo items download completed...")
    }
    
    func getPhoto(item: Item) async throws -> UIImage {
        print("Downloading photo \(item.name)...")
        self.isLoading = true
        let image = try await StorageManager2.shared.getImageFrom(item: item)
        self.isLoading = false
        DispatchQueue.main.async {
            self.retrievedPhotos.append(image)
        }
        print("😎 Image \(item.name) download completed...")
        return image
    }
}

// MARK: Documents
extension UploaderViewModel {
    
    func uploadDocument(data: Data?) async throws {
        print("Uploading document...")
        self.isLoading = true

        guard let data = data else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        // Creo id per il doc
        let idItem = UUID().uuidString
        
        // Creo l'item
        let item = Item(id: idItem,
                        user: user,
                        ext: "pdf",
                        type: .document,
                        size: CGFloat(data.count),
                        date: Date().italianDate())
        
        let _ = try await StorageManager2.shared.saveDocument(data: data, item: item) // Salvo in Storage

        let _ = try await DataManager.shared.uploadItem(type: .document, item: item) // Salvo in Firestore

        self.isLoading = false
        
        // Ricarico gli items
        //try await downloadPhotoItems()
        print("😎 Document upload completed!")
    }
    
    func downloadDocumentItems() async throws {
        print("Downloading document items...")
        self.isLoading = true
        self.itemsDocument = []
        self.itemsDocument = try await DataManager.shared.getOwnItems(type: .document)
        self.isLoading = false
        print("😎 Document items download completed...")
    }
    
    func getDocumentData(item: Item) async throws -> Data {
        print("Downloading document \(item.name)...")
        self.isLoading = true
        let data = try await StorageManager2.shared.getDataFrom(item: item)
        self.isLoading = false
//        DispatchQueue.main.async {
//            self.retrievedPhotos.append(image)
//        }
        print("😎 Document \(item.name) download completed...")
        return data
    }
}

// MARK: Video
extension UploaderViewModel {
    
    func uploadVideo(data: Data?) async throws {
        print("Uploading video...")
        self.isLoading = true

        guard let data = data else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        
        // Creo id per il doc
        let idItem = UUID().uuidString
        
        // Creo l'item
        let item = Item(id: idItem,
                        user: user,
                        ext: "mp4",
                        type: .video,
                        size: CGFloat(data.count),
                        date: Date().italianDate())
        
        let _ = try await StorageManager2.shared.saveVideo(data: data, item: item) // Salvo in Storage

        let _ = try await DataManager.shared.uploadItem(type: .video, item: item) // Salvo in Firestore

        self.isLoading = false
        
        // Ricarico gli items
        //try await downloadPhotoItems()
        print("😎 Video upload completed!")
    }
    
    func downloadVideoItems() async throws {
        print("Downloading video items...")
        self.isLoading = true
        self.itemsVideo = []
        self.itemsVideo = try await DataManager.shared.getOwnItems(type: .video)
        self.isLoading = false
        print("😎 Video items download completed...")
    }
    
    func getVideoData(item: Item) async throws -> Data {
        print("Downloading video \(item.name)...")
        self.isLoading = true
        let data = try await StorageManager2.shared.getDataFrom(item: item)
        self.isLoading = false
//        DispatchQueue.main.async {
//            self.retrievedPhotos.append(image)
//        }
        print("😎 Video \(item.name) download completed...")
        return data
    }
}
