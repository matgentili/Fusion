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

class UploaderViewModel: ObservableObject {
    
    @Published var retrievedImages: [UIImage] = []
    
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
        
        // Specify the file path and name
        let path = "images/\(UUID().uuidString).jpg"
        let imageRef = storageRef.child(path)
        
        // Upload that data
        let uploadTask = imageRef.putData(imageData, metadata: nil){ metadata, error in
            if error == nil && metadata != nil {
                // Save a referente to the file in Firestore DB
                let db = Firestore.firestore()
                db.collection("images").document().setData(["url": path])
            }
        }
    }
    
    func retrieveImage(){
        // Get the data from the database
        let db = Firestore.firestore()

        db.collection("images").getDocuments(completion: { snapshot, error in
            if error == nil && snapshot != nil {
                var paths = [String]()
                snapshot?.documents.forEach { doc in
                    // Extract the file path and add to paths
                    paths.append(doc["url"] as! String)
                }
                
                // Storage reference
                let storageRef = Storage.storage().reference()
                
                // Loop through each file path and fetch the data from storage
                paths.forEach { path in
                    // Specify the path
                    let fileRef = storageRef.child(path)
                    
                    // Retriece the data
                    fileRef.getData(maxSize: 5 * 1024 * 1024, completion: { data, error in
                        
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
