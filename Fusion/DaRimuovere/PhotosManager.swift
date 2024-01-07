////
////  PhotosManager.swift
////  Fusion
////
////  Created by Matteo Gentili on 06/01/24.
////
//
//import Foundation
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//import FirebaseAuth
//
//final class PhotosManager {
//    
//    static let shared = PhotosManager()
//    private init() { }
//    private let photoCollection = Firestore.firestore().collection("photos")
//    private var user: User {
//        return Auth.auth().currentUser!
//    }
//    
//    private func photoDocument(id: String) -> DocumentReference {
//        photoCollection.document(id)
//    }
//    
//    func uploadItem(item: Item) async throws {
//        try photoDocument(id: item.id).setData(from: item, merge: false)
//    }
//    
//    func getItem(id: String) async throws -> Item {
//        try await photoDocument(id: id).getDocument(as: Item.self)
//    }
//    
//    func getOwnItems() async throws -> [Item] {
//        do {
//            // Esegui la query e attendi il risultato
//            let querySnapshot = try await photoCollection
//                .whereField("uidOwner", isEqualTo: user.uid)
//                .getDocuments()
//            // Mappa i dati direttamente in un array di Item usando compactMap
//            let items = try querySnapshot.documents.compactMap { doc in
//                return try doc.data(as: Item.self)
//            }
//            return items
//        } catch {
//            // Gestisci gli errori se la richiesta fallisce
//            throw error
//        }
//    }
//    
//    func getSharedItems() async throws -> [Item] {
//        do {
//            // Esegui la query e attendi il risultato
//            let querySnapshot = try await photoCollection
//                .whereField("shared", arrayContains: user.email ?? "")
//                .getDocuments()
//            // Mappa i dati direttamente in un array di Item usando compactMap
//            let items = try querySnapshot.documents.compactMap { doc in
//                return try doc.data(as: Item.self)
//            }
//            return items
//        } catch {
//            // Gestisci gli errori se la richiesta fallisce
//            throw error
//        }
//    }
//    
//}
