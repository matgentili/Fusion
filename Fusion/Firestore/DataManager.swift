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
    
    private let usersCollection = Firestore.firestore().collection(Utils.usersCollection)
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
    
    func getProfileData() async throws -> Profile? {
        print("Retrieve profile...")
        do {
            let querySnapshot = try await usersCollection.whereField("id", isEqualTo: user.uid)
                .getDocuments()
            guard let doc = querySnapshot.documents.first, let profile = try? doc.data(as: Profile.self) else {
                try await saveProfileData()
                return nil
            }
            print("Profile retrieved...")
            return profile
        } catch {
            throw error
        }
    }
    
    func saveProfileData() async throws {
        print("Saving Profile...")
        do {
            
            let profile = Profile(id: user.uid, email: user.email ?? "", space_Byte: 1073741824)
            guard let dic = profile.toDictionary() else {
                return
            }
            let _ = try await usersCollection.document(user.uid).setData(dic, merge: false)
            print("Profile saved...")
        } catch {
            // Gestisci gli errori se la richiesta fallisce
            throw error
        }
    }
}

struct Profile: Codable, Identifiable {
    var id: String
    var space_Byte: Double
    var email: String
    
    var space_GB: Double {
        return space_Byte / (1024 * 1024 * 1024)
    }
    
    func toDictionary() -> [String: Any]?{
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(self)
            if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                return dictionary
            }
        } catch {
            print("Errore durante la conversione dell'oggetto in dizionario: \(error.localizedDescription)")
        }
        return nil
    }
    
    init(id: String, email: String, space_Byte: Double){
        self.id = id
        self.email = email
        self.space_Byte = space_Byte
    }
    
    
    // Conform to the Decodable protocol
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.space_Byte = try container.decode(Double.self, forKey: .space_Byte)
    }
}
