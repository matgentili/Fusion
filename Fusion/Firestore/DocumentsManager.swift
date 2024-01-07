//
//  DocumentsManager.swift
//  Fusion
//
//  Created by Matteo Gentili on 07/01/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

final class DocumentsManager {
    
    static let shared = DocumentsManager()
    private init() { }
    private let documentCollection = Firestore.firestore().collection("documents")
    private var user: User {
        return Auth.auth().currentUser!
    }
    
    private func documentDocument(id: String) -> DocumentReference {
        documentCollection.document(id)
    }
    
    func uploadItem(item: Item) async throws {
        try documentDocument(id: item.id).setData(from: item, merge: false)
    }
    
    func getItem(id: String) async throws -> Item {
        try await documentDocument(id: id).getDocument(as: Item.self)
    }
    
    func getOwnItems() async throws -> [Item] {
        do {
            // Esegui la query e attendi il risultato
            let querySnapshot = try await documentCollection
                .whereField("uidOwner", isEqualTo: user.uid)
                .getDocuments()
            // Mappa i dati direttamente in un array di Item usando compactMap
            let items = try querySnapshot.documents.compactMap { doc in
                return try doc.data(as: Item.self)
            }
            return items
        } catch {
            // Gestisci gli errori se la richiesta fallisce
            throw error
        }
    }
    
    func getSharedItems() async throws -> [Item] {
        do {
            // Esegui la query e attendi il risultato
            let querySnapshot = try await documentCollection
                .whereField("shared", arrayContains: user.email ?? "")
                .getDocuments()
            // Mappa i dati direttamente in un array di Item usando compactMap
            let items = try querySnapshot.documents.compactMap { doc in
                return try doc.data(as: Item.self)
            }
            return items
        } catch {
            // Gestisci gli errori se la richiesta fallisce
            throw error
        }
    }
    
}
