//
//  Product.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import Foundation
import UIKit
import SwiftUI
import SirioKitIOS
struct Product: Identifiable, Equatable {
    var category: ProductCategory
    var percent: Double
    var primaryColor: Color
    var secondaryColor: Color
    var id = UUID()
    
    var icon: AwesomeIcon {
        switch category {
        case .documents:
            return .folder
        case .photos:
            return .photoVideo
        case .media:
            return .fileVideo
        case .free:
            return .star
        }
    }
    
    static var preview: [Product] =  [
        .init(category: ProductCategory.documents, percent: 0.20, primaryColor: Color.colorDocumentsPrimary, secondaryColor: Color.colorDocumentsSecondary),
        .init(category: ProductCategory.photos, percent: 0.30, primaryColor: Color.colorPhotosPrimary, secondaryColor: Color.colorPhotosSecondary),
        .init(category: ProductCategory.media, percent: 0.18, primaryColor: Color.colorMediaPrimary, secondaryColor: Color.colorMediaSecondary),
        .init(category: ProductCategory.free, percent: 0.32, primaryColor: Color.gray.opacity(0.8), secondaryColor: Color.gray.opacity(0.8))
    ]
}

enum ProductCategory: String {
    case documents = "Documents"
    case photos = "Photos"
    case media = "Media"
    case free = "Free"
}

