//
//  UploaderViewModel.swift
//  Fusion
//
//  Created by Matteo Gentili on 27/12/23.
//

import UIKit
import SwiftUI
import Firebase
import FirebaseStorage
import Combine

class UploaderViewModel: ObservableObject {
    
    @Published var retrievedPhotos: [UIImage] = []
    @Published var itemsPhoto: [Item] = []
    @Published var itemsDocument: [Item] = []
    @Published var itemsVideo: [Item] = []
    @Published var isLoading: Bool = false
    
    let db = Firestore.firestore()

    var pathPhotos: String {
        return "photos"
    }
    
    var pathDocuments: String {
        return "documents"
    }
    
    var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    var email: String {
        return Auth.auth().currentUser?.email ?? ""
    }
    
    init() {
        downloadImagesName()
    }
}

// Documents
extension UploaderViewModel {
    func uploadDocument(data: Data?, ext: String){
        self.isLoading = true
        guard let data = data else {
            self.isLoading = false
            return
        }
        
        let storageRef = Storage.storage().reference()
        let uidDocument = UUID().uuidString // id document
        let path = "\(pathDocuments)/\(uidDocument).\(ext)" // path documento
        let documentRef = storageRef.child(path)
        
        // Upload that data
        let _ = documentRef.putData(data, metadata: nil){ metadata, error in
            if error == nil && metadata != nil {
                // Referece
                //let userDocumentRef = db.collection("users").document(self.uid)
                let documentsCollectionRef = self.db.collection("documents")
                let item = Item(id: uidDocument, uidOwner: self.uid, emailOwner: self.email, path: path)
                guard let dictionary = item.toDictionary() else {
                    self.isLoading = false
                    return
                }
                let _ = documentsCollectionRef.addDocument(data: dictionary) { (error) in
                    if let error = error {
                        print("Errore durante l'aggiunta del documento: \(error.localizedDescription)")
                    } else {
                        print("😎 Documento aggiunto con successo.")
                    }
                    self.isLoading = false
                }
                
                if error == nil {
                    
                }
            }
        }
    }
}

// Photos
extension UploaderViewModel {
    // Upload image
    func uploadImage(image: UIImage?){
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
        let path = "\(pathPhotos)/\(uidPhoto).jpg" // path immagine
        let imageRef = storageRef.child(path)
        
        // Upload that data
        let _ = imageRef.putData(imageData, metadata: nil){ metadata, error in
            if error == nil && metadata != nil {
                // Referece
                // let userDocumentRef = db.collection("users").document(self.uid)
                let imagesCollectionRef = self.db.collection("photos")
                let item = Item(id: uidPhoto, uidOwner: self.uid, emailOwner: self.email, path: path)
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
    
    func downloadImagesName(){
        self.isLoading = true
        self.itemsPhoto = []
        // Reference
        //let userDocumentRef = db.collection("users").document(uid)
        let imagesCollectionRef = db.collection("photos")
        
        imagesCollectionRef.whereField("uidOwner", isEqualTo: self.uid).getDocuments(completion: { snapshot, error in
            if let error = error {
                // Gestisci l'errore qui
                print("Errore durante il recupero dei documenti: \(error.localizedDescription)")
                self.isLoading = false
                return
            }
            
            snapshot?.documents.forEach { doc in
                do {
                    let item = try doc.data(as: Item.self)
                    self.itemsPhoto.append(item)
                    
                    if doc == snapshot?.documents.last {
                        self.isLoading = false
                    }
                    
                } catch {
                    // Gestisci l'errore di conversione dei dati qui
                    print("Errore durante la conversione dei dati: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
            self.isLoading = false
        })
    }
    
    func downloadPhotoFrom(item: Item){
        self.isLoading = true
        // Reference
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(item.path)
        
        // Retrieve the data
        fileRef.getData(maxSize: 10 * 1024 * 1024, completion: { data, error in
            
            if let data = data, error == nil {
                // Get the image data in storage for each image reference
                guard let image = UIImage(data: data) else {
                    self.isLoading = false
                    return
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.retrievedPhotos.append(image)
                }
            }
        })
    }
}

extension UploaderViewModel {
    func update(item: Item){
        self.isLoading = true
        let imagesCollectionRef = db.collection("photos")
        
        imagesCollectionRef
            .whereField("uidOwner", isEqualTo: self.uid)
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
