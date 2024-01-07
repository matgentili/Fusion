//
//  Item.swift
//  Fusion
//
//  Created by Matteo Gentili on 29/12/23.
//

import Foundation
import SwiftUI
import SirioKitIOS
import FirebaseAuth
import Firebase
import FirebaseFirestore

struct Item: Codable, Identifiable {
    var id: String
    var uidOwner: String?
    var emailOwner: String?
    var ext: String?
    var type: ItemType?
    var size: CGFloat?
    var date: String?
    var shared: [String]?
    
    var path: String {
        return "\(type?.getPath() ?? "")/\(id).\(ext ?? "")"
    }
    
    var name: String {
        return "\(id).\(ext ?? "")"
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
    
    init(id: String, user: User, ext: String, type: ItemType, size: CGFloat, date: String, shared: [String] = []){
        self.id = id
        self.uidOwner = user.uid
        self.emailOwner = user.email
        self.ext = ext
        self.type = type
        self.size = size
        self.date = date
        self.shared = shared
    }
    
    init(id: String, uidOwner: String, emailOwner: String, ext: String, type: ItemType, size: CGFloat, date: String, shared: [String] = []){
        self.id = id
        self.uidOwner = uidOwner
        self.emailOwner = emailOwner
        self.ext = ext
        self.type = type
        self.size = size
        self.date = date
        self.shared = shared
    }
    
    // Conform to the Decodable protocol
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.uidOwner = try container.decodeIfPresent(String.self, forKey: .uidOwner)
        self.emailOwner = try container.decodeIfPresent(String.self, forKey: .emailOwner)
        self.ext = try container.decodeIfPresent(String.self, forKey: .ext)
        self.type = try container.decodeIfPresent(ItemType.self, forKey: .type)
        self.size = try container.decodeIfPresent(CGFloat.self, forKey: .size)
        self.date = try container.decodeIfPresent(String.self, forKey: .date)
        self.shared = try container.decodeIfPresent([String].self, forKey: .shared)
    }
    
    
    static var preview: Item = .init(id: "1", uidOwner: "1", emailOwner: "test@gmail.com", ext: "pdf", type: .document, size: 1123.89, date: "11/11/2024 10:23:24")
    
    
    mutating func addSharedUser(email: String) {
        self.shared?.append(email)
    }
}


enum ItemType: String, Codable {
    case document = "Document"
    case photo = "Photo"
    case video = "Video"
    //    case free = "Free"
    
    
    func getPrimaryColor() -> Color {
        switch self {
        case .document:
            return Color.colorDocumentsPrimary
        case .photo:
            return Color.colorPhotosPrimary
        case .video:
            return Color.colorVideosPrimary
            // ...
        }
    }
    
    func getSecondaryColor() -> Color {
        switch self {
        case .document:
            return Color.colorDocumentsSecondary
        case .photo:
            return Color.colorPhotosSecondary
        case .video:
            return Color.colorVideosSecondary
            // ...
        }
    }
    
    func getIcon() -> AwesomeIcon? {
        switch self {
        case .document:
            return .folder
        case .photo:
            return .photoVideo
        case .video:
            return .fileVideo
        }
    }
    
    func getPath() -> String {
        switch self {
        case .document:
            return "documents"
        case .photo:
            return "photos"
        case .video:
            return "videos"
        }
    }
}
