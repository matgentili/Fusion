//
//  Item.swift
//  Fusion
//
//  Created by Matteo Gentili on 29/12/23.
//

import Foundation
import SwiftUI
import SirioKitIOS

struct Item: Codable, Identifiable {
    var id: String
    var uidOwner: String?
    var emailOwner: String?
    var path: String?
    var ext: String?
    var type: ItemType?
    var size: CGFloat?
    var date: String?
    var shared: [String]?
    
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
    
    init(id: String, uidOwner: String, emailOwner: String, path: String, ext: String, type: ItemType, size: CGFloat, date: String, shared: [String] = []){
        self.id = id
        self.uidOwner = uidOwner
        self.emailOwner = emailOwner
        self.path = path
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
        self.path = try container.decodeIfPresent(String.self, forKey: .path)
        self.ext = try container.decodeIfPresent(String.self, forKey: .ext)
        self.type = try container.decodeIfPresent(ItemType.self, forKey: .type)
        self.size = try container.decodeIfPresent(CGFloat.self, forKey: .size)
        self.date = try container.decodeIfPresent(String.self, forKey: .date)
        self.shared = try container.decodeIfPresent([String].self, forKey: .shared)
    }
    
    
    static var preview: Item = .init(id: "1", uidOwner: "1", emailOwner: "test@gmail.com", path: "path", ext: "pdf", type: .documents, size: 1123.89, date: "11/11/2024 10:23:24")
}


enum ItemType: String, Codable {
    case documents = "Documents"
    case photos = "Photos"
    case videos = "Videos"
    //    case free = "Free"
    
    
    func getPrimaryColor() -> Color {
        switch self {
        case .documents:
            return Color.colorDocumentsPrimary
        case .photos:
            return Color.colorPhotosPrimary
        case .videos:
            return Color.colorVideosPrimary
            // ...
        }
    }
    
    func getSecondaryColor() -> Color {
        switch self {
        case .documents:
            return Color.colorDocumentsSecondary
        case .photos:
            return Color.colorPhotosSecondary
        case .videos:
            return Color.colorVideosSecondary
            // ...
        }
    }
    
    func getIcon() -> AwesomeIcon? {
        switch self {
        case .documents:
            return .folder
        case .photos:
            return .photoVideo
        case .videos:
            return .fileVideo
        }
    }
}
