//
//  SharedItemsViewModel.swift
//  Fusion
//
//  Created by Matteo Gentili on 07/01/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Combine

@MainActor
class SharedItemsViewModel: ObservableObject {
    
    @Published var itemsPhotoShared: [Item] = []
    @Published var itemsDocumentShared: [Item] = []
    @Published var itemsVideoShared: [Item] = []
    @Published var isLoading: Bool = false
    
    var cancellables: Set<AnyCancellable> = []
    
    let db = Firestore.firestore()
    
    var user: User {
        return Auth.auth().currentUser!
    }
    
    init() {
        Task {
            do {
                try await downloadPhotoItemsShared()
                try await downloadDocumentItemsShared()
                try await downloadVideoItemsShared()
            } catch {
                // Gestisci gli errori, ad esempio, stampandoli in console
                print("Errore durante il download degli elementi condivisi: \(error)")
            }
        }
    }
}

// Photo
extension SharedItemsViewModel {
    func downloadPhotoItemsShared() async throws {
        print("Downloading shared photo items...")
        self.isLoading = true
        self.itemsPhotoShared = []
        self.itemsPhotoShared = try await DataManager.shared.getSharedItems(type: .photo)
        self.isLoading = false
        print("😎 Shared Photo items download completed...")
    }
    
    func downloadDocumentItemsShared() async throws {
        print("Downloading shared document items...")
        self.isLoading = true
        self.itemsDocumentShared = []
        self.itemsDocumentShared = try await DataManager.shared.getSharedItems(type: .document)
        self.isLoading = false
        print("😎 Shared document items download completed...")
    }
    
    func downloadVideoItemsShared() async throws {
        print("Downloading shared video items...")
        self.isLoading = true
        self.itemsVideoShared = []
        self.itemsVideoShared = try await DataManager.shared.getSharedItems(type: .video)
        self.isLoading = false
        print("😎 Shared video items download completed...")
    }
}
