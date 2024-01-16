//
//  HomeViewModel.swift
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
class HomeViewModel: ObservableObject {
    
    @Published var retrievedPhotos: [UIImage] = []
    @Published var itemsPhoto: [Item] = [] {
        didSet {
            createChartData()
        }
    }
    @Published var itemsDocument: [Item] = [] {
        didSet {
            createChartData()
        }
    }
    @Published var itemsVideo: [Item] = [] {
        didSet {
            createChartData()
        }
    }
    
    @Published var itemsPhotoShared: [Item] = [] 
//    {
//        didSet {
//            self.itemsShared = []
//            self.itemsShared = itemsPhotoShared + itemsDocumentShared + itemsVideoShared
//        }
//    }
    
    @Published var itemsDocumentShared: [Item] = [] 
//    {
//        didSet {
//            self.itemsShared = []
//            self.itemsShared = itemsPhotoShared + itemsDocumentShared + itemsVideoShared
//        }
//    }
    
    @Published var itemsVideoShared: [Item] = [] 
//    {
//        didSet {
//            self.itemsShared = []
//            self.itemsShared = itemsPhotoShared + itemsDocumentShared + itemsVideoShared
//        }
//    }
    
    var itemsShared: [Item] {
        return itemsPhotoShared + itemsDocumentShared + itemsVideoShared
    }
    
    @Published var isLoading: Bool = false
    @Published var chartProducts: [Product] =  [
        .init(totalSpaceByte: 100, category: .photos, spaceUsedByte: 0, primaryColor: .colorPhotosPrimary, secondaryColor: .colorPhotosSecondary),
        .init(totalSpaceByte: 100, category: .documents, spaceUsedByte: 0, primaryColor: .colorDocumentsPrimary, secondaryColor: .colorDocumentsSecondary),
        .init(totalSpaceByte: 100, category: .videos, spaceUsedByte: 0, primaryColor: .colorVideosPrimary, secondaryColor: .colorVideosSecondary),
        .init(totalSpaceByte: 100, category: .free, spaceUsedByte: 100, primaryColor: .gray, secondaryColor: .gray.opacity(0.8)),
    ]
    @Published var profile: Profile!
    
    var cancellables: Set<AnyCancellable> = []
    
    let db = Firestore.firestore()
    
    var user: User {
        return Auth.auth().currentUser!
    }
    
    init() {
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    try? await self.fetchPhotosCollection()
                }
                group.addTask {
                    try? await self.fetchDocumentsCollection()
                }
                group.addTask {
                    try? await self.fetchVideosCollection()
                }
                group.addTask {
                    let profileData = try? await DataManager.shared.getProfileData()
                    
                    await MainActor.run {
                        self.profile = profileData
                    }
                }
                
                // Attendere che tutte le attività siano state completate
                for await _ in group {}
                
                // Ora puoi eseguire un'azione dopo che tutte e tre le chiamate sono state completate
                DispatchQueue.main.async {
                    // Esegui l'azione qui
                    print("Tutte e tre le chiamate sono state completate!")
                    self.createChartData()
                }
            }
            
            try await downloadSharedItems()
        }
    }

    
    func createChartData() {
        if profile != nil {
            let spaceUsedPhoto = itemsPhoto.reduce(0.0) { $0 + ($1.size ?? 0.0) }
            let spaceUsedDocument = itemsDocument.reduce(0.0) { $0 + ($1.size ?? 0.0) }
            let spaceUsedVideo = itemsVideo.reduce(0.0) { $0 + ($1.size ?? 0.0) }
            let spaceFree = profile.space_Byte - spaceUsedPhoto - spaceUsedDocument - spaceUsedVideo
            
            if chartProducts.last?.spaceUsedByte == 100 {
                chartProducts = [
                    .init(totalSpaceByte: profile.space_Byte, category: .photos, spaceUsedByte: spaceUsedPhoto, primaryColor: .colorPhotosPrimary, secondaryColor: .colorPhotosSecondary),
                    .init(totalSpaceByte: profile.space_Byte, category: .documents, spaceUsedByte: spaceUsedDocument, primaryColor: .colorDocumentsPrimary, secondaryColor: .colorDocumentsSecondary),
                    .init(totalSpaceByte: profile.space_Byte, category: .videos, spaceUsedByte: spaceUsedVideo, primaryColor: .colorVideosPrimary, secondaryColor: .colorVideosSecondary),
                    .init(totalSpaceByte: profile.space_Byte, category: .free, spaceUsedByte: spaceFree, primaryColor: .gray, secondaryColor: .gray.opacity(0.8)),
                ]
            } else {
                withAnimation {
                    chartProducts[0].spaceUsedByte = spaceUsedPhoto
                    chartProducts[1].spaceUsedByte = spaceUsedDocument
                    chartProducts[2].spaceUsedByte = spaceUsedVideo
                    chartProducts[3].spaceUsedByte = spaceFree
                }
            }
        }
    }
}

// MARK: Metodi in comune
extension HomeViewModel {
    func updateItem(item: Item, updatedItem: Item) async throws {
        print("Updating item...")
        self.isLoading = true
        try await DataManager.shared.updateItem(item: item, updatedItem: updatedItem)
        self.isLoading = false
        print("😎 Item update completed...")
    }
    
    func deleteItem(item: Item) async throws {
        print("Deleting item...")
        self.isLoading = true
        try await DataManager.shared.deleteItem(item: item)
        self.isLoading = false
        print("😎 Item delete completed...")
    }
    
    func updateItemShared(item: Item, updatedItem: Item, uid: String?) async throws {
        print("Updating item...")
        self.isLoading = true
        try await DataManager.shared.updateItemShared(item: item, updatedItem: updatedItem, uid: uid)
        self.isLoading = false
        print("😎 Item update completed...")
    }
    
}

// MARK: Photos
extension HomeViewModel {
    
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
                        size: Double(data.count),
                        date: Date().italianDate())
        
        let _ = try await StorageManager2.shared.saveImage(image: image, item: item) // Salvo in Storage
        
        let _ = try await DataManager.shared.uploadItem(type: .photo, item: item) // Salvo in Firestore
        
        self.isLoading = false
        
        // Ricarico gli items
        try await fetchPhotosCollection()
        print("😎 Image upload completed!")
    }
    
    func fetchPhotosCollection() async throws {
        print("Downloading photo items...")
        self.isLoading = true
        self.itemsPhoto = []
        self.itemsPhoto = try await DataManager.shared.getOwnItems(type: .photo) ?? []
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
extension HomeViewModel {
    
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
                        size: Double(data.count),
                        date: Date().italianDate())
        
        let _ = try await StorageManager2.shared.saveDocument(data: data, item: item) // Salvo in Storage
        
        let _ = try await DataManager.shared.uploadItem(type: .document, item: item) // Salvo in Firestore
        
        self.isLoading = false
        
        // Ricarico gli items
        try await fetchDocumentsCollection()
        print("😎 Document upload completed!")
    }
    
    func fetchDocumentsCollection() async throws {
        print("Downloading document items...")
        self.isLoading = true
        self.itemsDocument = []
        self.itemsDocument = try await DataManager.shared.getOwnItems(type: .document) ?? []
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
extension HomeViewModel {
    
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
                        size: Double(data.count),
                        date: Date().italianDate())
        
        let _ = try await StorageManager2.shared.saveVideo(data: data, item: item) // Salvo in Storage
        
        let _ = try await DataManager.shared.uploadItem(type: .video, item: item) // Salvo in Firestore
        
        self.isLoading = false
        
        // Ricarico gli items
        try await fetchVideosCollection()
        print("😎 Video upload completed!")
    }
    
    func fetchVideosCollection() async throws {
        print("Downloading video items...")
        self.isLoading = true
        self.itemsVideo = []
        self.itemsVideo = try await DataManager.shared.getOwnItems(type: .video) ?? []
        self.isLoading = false
        print("😎 Video items download completed...")
    }
    
    func getVideoData(item: Item) async throws -> Data {
        print("Downloading video \(item.name)...")
        self.isLoading = true
        let data = try await StorageManager2.shared.getDataFrom(item: item)
        self.isLoading = false
        print("😎 Video \(item.name) download completed...")
        return data
    }
}

// Shared
extension HomeViewModel {
    
    func downloadSharedItems() async throws {
        try? await downloadPhotoItemsShared()
        try? await downloadDocumentItemsShared()
        try? await downloadVideoItemsShared()
    }
    
    func downloadPhotoItemsShared() async throws {
        print("Downloading shared photo items...")
        self.isLoading = true
        self.itemsPhotoShared = []
        self.itemsPhotoShared = try await DataManager.shared.getSharedItems(type: .photo) ?? []
        self.isLoading = false
        print("😎 Shared Photo items download completed...")
    }
    
    func downloadDocumentItemsShared() async throws {
        print("Downloading shared document items...")
        self.isLoading = true
        self.itemsDocumentShared = []
        self.itemsDocumentShared = try await DataManager.shared.getSharedItems(type: .document) ?? []
        self.isLoading = false
        print("😎 Shared document items download completed...")
    }
    
    func downloadVideoItemsShared() async throws {
        print("Downloading shared video items...")
        self.isLoading = true
        self.itemsVideoShared = []
        self.itemsVideoShared = try await DataManager.shared.getSharedItems(type: .video) ?? []
        self.isLoading = false
        print("😎 Shared video items download completed...")
    }
}
