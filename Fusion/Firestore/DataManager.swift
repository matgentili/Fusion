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
    
    private func itemCollection(forType type: ItemType) -> CollectionReference {
        switch type {
        case .document:
            return documentsCollection
        case .photo:
            return photosCollection
        case .video:
            return videosCollection
        }
    }
    
    private func getItemDocument(type: ItemType, id: String) -> DocumentReference {
        return itemCollection(forType: type).document(id)
    }
    
    func uploadItem(type: ItemType, item: Item) async throws {
        try getItemDocument(type: type, id: item.id).setData(from: item, merge: false)
    }
    
    func getItem(type: ItemType, id: String) async throws -> Item {
        try await getItemDocument(type: type, id: id).getDocument(as: Item.self)
    }
    
    func getOwnItems(type: ItemType) async throws -> [Item] {
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
    
    func getSharedItems(type: ItemType) async throws -> [Item] {
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
    
    func updateItem(item: Item, updatedItem: Item) async throws {
        do {
            // Esegui la query e attendi il risultato
            let querySnapshot = try await itemCollection(forType: item.type!)
                .whereField("uidOwner", isEqualTo: user.uid)
                .whereField("id", isEqualTo: item.id)
                .getDocuments()
            // Mappa i dati direttamente in un array di Item usando compactMap
            
            guard let doc = querySnapshot.documents.first, let dic = updatedItem.toDictionary() else {
                return
            }
            
            try await doc.reference.updateData(dic)
        } catch {
            // Gestisci gli errori se la richiesta fallisce
            throw error
        }
    }
}
