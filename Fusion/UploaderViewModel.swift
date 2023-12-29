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
    
    var pathPhotos: String {
        return "\(uid)/photos"
    }
    
    var uid: String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    init() {
        retrieveImages()
    }
}

// Photos
extension UploaderViewModel {
    // Upload image
    func uploadImage(image: UIImage?){
        guard let image = image else {
            return
        }
        // Create storage reference
        let storageRef = Storage.storage().reference()
        
        // Turn our image into data, and check if the conversion is ok
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        let db = Firestore.firestore()
        let uidPhoto = UUID() // id immagine
        // Specify the file path and name
        let path = "\(pathPhotos)/\(uidPhoto).jpg" // path immagine
        let imageRef = storageRef.child(path)
        
        // Upload that data
        let _ = imageRef.putData(imageData, metadata: nil){ metadata, error in
            if error == nil && metadata != nil {
                // Referece
                let userDocumentRef = db.collection("users").document(self.uid)
                let imagesCollectionRef = userDocumentRef.collection("photos")
                let item = Item(id: uidPhoto, user: self.uid, path: path)
                guard let dictionary = item.toDictionary() else {
                    return
                }
                let _ = imagesCollectionRef.addDocument(data: dictionary) { (error) in
                    if let error = error {
                        print("Errore durante l'aggiunta del documento: \(error.localizedDescription)")
                    } else {
                        print("Documento aggiunto con successo.")
                    }
                }
                
                if error == nil {
                    DispatchQueue.main.async {
                        self.retrievedPhotos.append(image)
                    }
                }
            }
        }
    }
    
    func retrieveImages(){
        self.itemsPhoto = []
        // Reference
        let db = Firestore.firestore()
        let userDocumentRef = db.collection("users").document(uid)
        let imagesCollectionRef = userDocumentRef.collection("photos")
        
        imagesCollectionRef.getDocuments(completion: { snapshot, error in
            if let error = error {
                // Gestisci l'errore qui
                print("Errore durante il recupero dei documenti: \(error.localizedDescription)")
                return
            }
            
            snapshot?.documents.forEach { doc in
                do {
                    let item = try doc.data(as: Item.self)
                    self.itemsPhoto.append(item)
                } catch {
                    // Gestisci l'errore di conversione dei dati qui
                    print("Errore durante la conversione dei dati: \(error.localizedDescription)")
                }
            }
        })
    }
    
    func downloadItem(item: Item){
        // Reference
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(item.path)
        
        // Retrieve the data
        fileRef.getData(maxSize: 10 * 1024 * 1024, completion: { data, error in
            
            if let data = data, error == nil {
                // Get the image data in storage for each image reference
                guard let image = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    self.retrievedPhotos.append(image)
                }
            }
        })
    }
}
