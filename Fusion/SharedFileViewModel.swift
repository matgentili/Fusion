//
//  SharedFileViewModel.swift
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
class SharedFileViewModel: ObservableObject {
    
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
        
    }
}

// Photo
extension SharedFileViewModel {
    func downloadPhotoItemsShared() async throws {
        print("Downloading images item shared...")
        self.isLoading = true
        self.itemsPhotoShared = []
        self.itemsPhotoShared = try await PhotosManager.shared.getSharedItems()
        self.isLoading = false
        print("😎 Images item download shared completed...")
    }
}
