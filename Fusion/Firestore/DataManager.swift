//
//  DataManager.swift
//  Fusion
//
//  Created by Matteo Gentili on 07/01/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class DataManager {
    
    static let shared = DataManager()
    private let db = Firestore.firestore()
    private let documentsCollection = Firestore.firestore().collection(Utils.documentsCollection)
    private let photosCollection = Firestore.firestore().collection(Utils.photosCollection)
    private let videosCollection = Firestore.firestore().collection(Utils.videosCollection)
    
    private var user: User {
        return Auth.auth().currentUser!
    }
    
    private func itemCollection(forType type: DataType) -> CollectionReference {
        switch type {
        case .document:
            return documentsCollection
        case .photo:
            return photosCollection
        case .video:
            return videosCollection
        }
    }
    
    private func getItemDocument(type: DataType, id: String) -> DocumentReference {
        return itemCollection(forType: type).document(id)
    }
    
    func uploadItem(type: DataType, item: Item) async throws {
        try getItemDocument(type: type, id: item.id).setData(from: item, merge: false)
    }
    
    func getItem(type: DataType, id: String) async throws -> Item {
        try await getItemDocument(type: type, id: id).getDocument(as: Item.self)
    }
    
    func getOwnItems(type: DataType) async throws -> [Item] {
        do {
            let querySnapshot = try await itemCollection(forType: type)
                .whereField("uidOwner", isEqualTo: user.uid)
                .getDocuments()
            let items = try querySnapshot.documents.compactMap { doc in
                return try doc.data(as: Item.self)
            }
            return items
        } catch {
            throw error
        }
    }
    
    func getSharedItems(type: DataType) async throws -> [Item] {
        do {
            let querySnapshot = try await itemCollection(forType: type)
                .whereField("shared", arrayContains: user.email ?? "")
                .getDocuments()
            let items = try querySnapshot.documents.compactMap { doc in
                return try doc.data(as: Item.self)
            }
            return items
        } catch {
            throw error
        }
    }
}

extension DataManager {
    enum DataType {
        case document
        case photo
        case video
    }
}
