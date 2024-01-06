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
    
    private let userCollection = Firestore.firestore().collection("users")

    
    init() {
        
    }
}



// Photos
extension UploaderViewModel {
    
    func uploadImageAsync(image: UIImage?) async throws {
        print("Uploading image...")
        self.isLoading = true
        guard let image = image else {
            self.isLoading = false
            return
        }
        // Salvo l'immagine nello storage
        let idItem = UUID().uuidString
        let _ = try await StorageManager.shared.saveImage(image: image, userId: user.uid, idItem: idItem)
        
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            throw URLError(.backgroundSessionWasDisconnected)
        }
        // Salvo item in Firestore
        let item = Item(id: idItem,
                        user: user,
                        ext: "jpeg",
                        type: .photo,
                        size: CGFloat(data.count),
                        date: Date().italianDate())
        let _ = try await PhotoManager.shared.uploadItem(item: item)
        self.isLoading = false
        
        // Ricarico gli items
        try await downloadPhotoItems()
        print("😎 Image upload completed!")
    }
    
    func downloadPhotoItems() async throws {
        print("Downloading images item...")
        self.isLoading = true
        self.itemsPhoto = []
        self.itemsPhoto = try await PhotoManager.shared.getOwnItems()
        self.isLoading = false
        print("😎 Images item download completed...")
    }
    
    func getPhoto(item: Item) async throws -> UIImage {
        print("Downloading image...")
        self.isLoading = true
        let image = try await StorageManager.shared.getImage(userId: user.uid, path: item.path)
        self.isLoading = false
        DispatchQueue.main.async {
            self.retrievedPhotos.append(image)
        }
        print("😎 Image download completed...")
        return image
    }
}

extension UploaderViewModel {
    func update(item: Item){
        self.isLoading = true
        let imagesCollectionRef = db.collection("photos")
        
        imagesCollectionRef
            .whereField("uidOwner", isEqualTo: user.uid)
            .whereField("id", isEqualTo: item.id)
            .getDocuments(completion: { snapshot, error in
                if let error = error {
                    // Gestisci l'errore qui
                    print("Errore durante il recupero dei documenti: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let doc = snapshot?.documents.first else {
                    self.isLoading = false
                    return
                }
                let dic: [String: Any] = [
                    "shared": ["test1", "test2"]
                ]
                doc.reference.updateData(dic)
                self.isLoading = false
            })
    }
}


//extension UploaderViewModel {
//    
//    private func userDocument(userId: String) -> DocumentReference {
//        userCollection.document(userId)
//    }
//    
//    func createNewUser() async throws {
//        var user = Auth.auth().currentUser
//
//        let userModel = User(id: self.uid, isAnonymous: user?.isAnonymous, date: Date(), email: user?.email, preferences: [])
//        try userDocument(userId: userModel.id).setData(from: userModel)
//        //try await Firestore.firestore().collection("users").document(self.uid).setData(userData, merge: false)
//    }
//    
//    func getUser(userId: String) async throws -> User {
//        let snapshot = try await userDocument(userId: self.uid).getDocument()
//        
//        let user = try snapshot.data(as: User.self)
//        
//        return user
//    }
//    
//    func addUserPrefenceres(userId: String, preference: String) async throws {
//        let data: [String: Any] = [
//            User.CodingKeys.preferences.rawValue: FieldValue.arrayUnion([preference])
//        ]
//        
//        try await userDocument(userId: userId).updateData(data)
//    }
//}
//
//
//struct User: Codable {
//    var id: String
//    var isAnonymous: Bool?
//    var date: Date?
//    var email: String?
//    var preferences: [String]?
//    
//    enum CodingKeys: String, CodingKey {
//        case id = "user_id"
//        case isAnonymous = "is_anonymous"
//        case date = "date_created"
//        case email = "email"
//        case preferences = "preferences"
//    }
//    
//    init(id: String, isAnonymous: Bool?, date: Date?, email: String?, preferences: [String]?) {
//        self.id = id
//        self.isAnonymous = isAnonymous
//        self.date = date
//        self.email = email
//        self.preferences = preferences
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(String.self, forKey: .id)
//        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
//        self.date = try container.decodeIfPresent(Date.self, forKey: .date)
//        self.email = try container.decodeIfPresent(String.self, forKey: .email)
//        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
//    }
//}


extension UploaderViewModel {
    /*
     // Upload image
     func uploadImage(image: UIImage?){
         let ext = "jpg"
         self.isLoading = true
         guard let image = image else {
             self.isLoading = false
             return
         }
         // Create storage reference
         let storageRef = Storage.storage().reference()
         
         // Turn our image into data, and check if the conversion is ok
         guard let imageData = image.jpegData(compressionQuality: 0.8) else {
             self.isLoading = false
             return
         }
         let uidPhoto = UUID().uuidString // id immagine
         // Specify the file path and name
         let path = "\(pathPhotos)/\(uidPhoto).\(ext)" // path immagine
         let imageRef = storageRef.child(path)
         let _ = imageRef.putData(imageData, metadata: nil){ metadata, error in
             if error == nil && metadata != nil {
                 // Referece
                 // let userDocumentRef = db.collection("users").document(self.uid)
                 let imagesCollectionRef = self.db.collection("photos")
                 let item = Item(id: uidPhoto, uidOwner: self.uid, emailOwner: self.email, path: path, ext: ext, type: .photos, size: CGFloat(imageData.count), date: Date().italianDate())
                 guard let dictionary = item.toDictionary() else {
                     return
                 }
                 
                 let _ = imagesCollectionRef.addDocument(data: dictionary) { (error) in
                     if let error = error {
                         print("Errore durante l'aggiunta del documento: \(error.localizedDescription)")
                         self.isLoading = false
                     } else {
                         print("Documento aggiunto con successo.")
                         self.isLoading = false
                     }
                 }
                 
                 if error == nil {
                     DispatchQueue.main.async {
                         self.downloadImagesName()
                         self.retrievedPhotos.append(image)
                     }
                 }
             }
         }
     }
     */
}


//
//// Documents
//extension UploaderViewModel {
//    func uploadDocument(data: Data?, ext: String){
//        self.isLoading = true
//        guard let data = data else {
//            self.isLoading = false
//            return
//        }
//        
//        let storageRef = Storage.storage().reference()
//        let uidDocument = UUID().uuidString // id document
//        let path = "\(pathDocuments)/\(uidDocument).\(ext)" // path documento
//        let documentRef = storageRef.child(path)
//        
//        // Upload that data
//        let _ = documentRef.putData(data, metadata: nil){ metadata, error in
//            if error == nil && metadata != nil {
//                // Referece
//                //let userDocumentRef = db.collection("users").document(self.uid)
//                let documentsCollectionRef = self.db.collection("documents")
//                let item = Item(id: uidDocument, uidOwner: self.uid, emailOwner: self.email, path: path, ext: ext, type: .documents, size: CGFloat(data.count), date: Date().italianDate())
//                guard let dictionary = item.toDictionary() else {
//                    self.isLoading = false
//                    return
//                }
//                let _ = documentsCollectionRef.addDocument(data: dictionary) { (error) in
//                    if let error = error {
//                        print("Errore durante l'aggiunta del documento: \(error.localizedDescription)")
//                    } else {
//                        print("😎 Documento aggiunto con successo.")
//                    }
//                    self.isLoading = false
//                }
//                
//                if error == nil {
//                    
//                }
//            }
//        }
//    }
//}


//
//    func downloadPhotoFrom(item: Item){
//        self.isLoading = true
//        // Reference
//        let storageRef = Storage.storage().reference()
//        let fileRef = storageRef.child(item.path ?? "")
//
//        // Retrieve the data
//        fileRef.getData(maxSize: 10 * 1024 * 1024, completion: { data, error in
//
//            if let data = data, error == nil {
//                // Get the image data in storage for each image reference
//                guard let image = UIImage(data: data) else {
//                    self.isLoading = false
//                    return
//                }
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    self.retrievedPhotos.append(image)
//                }
//            }
//        })
//    }
