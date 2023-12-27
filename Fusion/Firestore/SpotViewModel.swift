////
////  SpotViewModel.swift
////  Fusion
////
////  Created by Matteo Gentili on 27/12/23.
////
//
//import SwiftUI
//import Firebase
//import FirebaseStorage
//
//class SpotViewModel: ObservableObject {
//    
//    func saveImage(spot: Spot, photo: PhotoModel, image: UIImage) async -> Bool {
//        guard let spotID = spot.id else {
//            return false
//        }
//        
//        let photoName = UUID().uuidString
//        let storage = Storage.storage()
//        let storageRef = storage.reference().child("\(spotID)/\(photoName).jpeg")
//        
//        guard let resizedImage = image.jpegData(compressionQuality: 0.2) else {
//            print("Could not resize image")
//            return false
//        }
//        
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpg" // work also for png, jpeg
//        
//        var imageURLString = ""
//        
//        do {
//            let _ = try await storageRef.putDataAsync(resizedImage, metadata: metadata)
//            print("Image saved!")
//            do {
//                let imageURL = try await storageRef.downloadURL()
//                imageURLString = "\(imageURL)"
//            } catch {
//                print("Could not get imageURL after saving image \(error.localizedDescription)")
//                return false
//            }
//            
//        } catch {
//            print("Error uploading image to FirebaseStorage")
//            return false
//        }
//        
//        // Save the photos collection of the spot document spotID
//        
//        let collectionString = "spots/\(spotID)/photos"
//        let db = Firestore.firestore()
//        
//        do {
//            var newPhoto = photo
//            newPhoto.imageURLString = imageURLString
//            try await db.collection(collectionString).document(photoName).setData(newPhoto.dictionary)
//            print("Data updated successfully")
//            
//        } catch {
//            print("Coult not update data in photos for spotID \(spotID)")
//            
//        }
//    }
//}
