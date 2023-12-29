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
    
    @Published var retrievedImages: [UIImage] = []
    @Published var uid: String = ""
    
    
    var pathImages: String {
        return "\(uid)/images"
    }
    
    init() {
        
    }
    
    func set(uid: String){
        self.uid = uid
    }
    
    // Fare un metodo per scaricare soltanto i nomi e successivamente il file
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
        let uidImage = UUID()//.uuidString // id immagine
        // Specify the file path and name
        let path = "\(pathImages)/\(uidImage).jpg" // path immagine
        let imageRef = storageRef.child(path)
        
        // Upload that data
        let _ = imageRef.putData(imageData, metadata: nil){ metadata, error in
            if error == nil && metadata != nil {
                // Save a referente to the file in Firestore DB
                // Creazione del riferimento alla raccolta "users"
                let userDocumentRef = db.collection("users").document(self.uid)
                let imagesCollectionRef = userDocumentRef.collection("images")
                let item = Item(id: uidImage, user: self.uid, path: path)
                guard let dictionary = item.toDictionary() else {
                    return
                }
                let newImageDocumentRef = imagesCollectionRef.addDocument(data: dictionary) { (error) in
                    if let error = error {
                        print("Errore durante l'aggiunta del documento: \(error.localizedDescription)")
                    } else {
                        print("Documento aggiunto con successo.")
                    }
                }
                
                if error == nil {
                    DispatchQueue.main.async {
                        self.retrievedImages.append(image)
                    }
                }
            }
        }
    }
    
    func retrieveImages(){
        // Get the data from the database
        let db = Firestore.firestore()
        let userDocumentRef = db.collection("users").document(uid)
        let imagesCollectionRef = userDocumentRef.collection("images")

        imagesCollectionRef.getDocuments(completion: { snapshot, error in
            if error == nil && snapshot != nil {
                var paths = [String]()
                snapshot?.documents.forEach { doc in
                    
                    // Extract the file path and add to paths
                    paths.append(doc["path"] as! String)
                }
                
                // Storage reference
                let storageRef = Storage.storage().reference()
                
                // Loop through each file path and fetch the data from storage
                paths.forEach { path in
                    // Specify the path
                    let fileRef = storageRef.child(path)
                    
                    // Retrieve the data
                    fileRef.getData(maxSize: 10 * 1024 * 1024, completion: { data, error in
                        
                        if let data = data, error == nil {
                            // Get the image data in storage for each image reference
                            guard let image = UIImage(data: data) else {
                                return
                            }
                            DispatchQueue.main.async {
                                self.retrievedImages.append(image)
                            }
                        }
                    })
                }
            }
        })
        
        // Display the images
    }
}
