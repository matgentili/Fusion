//
//  PhotoModel.swift
//  Fusion
//
//  Created by Matteo Gentili on 27/12/23.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct PhotoModel: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = ""
    var description = ""
    var reviewer = Auth.auth().currentUser?.email ?? ""
    var postedOn = Date()
    
    
    var dictionary: [String: Any] {
        return ["imageURLString": imageURLString, "description": description, "reviewer": reviewer, "postedOn": Timestamp(date: postedOn)]
    }
}
