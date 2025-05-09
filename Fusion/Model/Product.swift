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
    var id = UUID()
    var totalSpaceByte: Double
    var category: ProductCategory
    var spaceUsedByte: Double
    var primaryColor: Color
    var secondaryColor: Color

    var percent: Double {
        guard totalSpaceByte != 0 else {
            return 0.0  // Evita divisione per zero
        }
        let value = (spaceUsedByte / totalSpaceByte * 100).rounded(to: 1)
        return value
    }
    
    var icon: AwesomeIcon {
        switch category {
        case .documents:
            return .folder
        case .photos:
            return .photoVideo
        case .videos:
            return .fileVideo
        case .free:
            return .star
        }
    }
//    
//    static var preview: [Product] =  [
//        .init(category: ProductCategory.documents, percent: 0.20, primaryColor: Color.colorDocumentsPrimary, secondaryColor: Color.colorDocumentsSecondary),
//        .init(category: ProductCategory.photos, percent: 0.30, primaryColor: Color.colorPhotosPrimary, secondaryColor: Color.colorPhotosSecondary),
//        .init(category: ProductCategory.videos, percent: 0.18, primaryColor: Color.colorVideosPrimary, secondaryColor: Color.colorVideosSecondary),
//        .init(category: ProductCategory.free, percent: 0.32, primaryColor: Color.gray.opacity(0.8), secondaryColor: Color.gray.opacity(0.8))
//    ]
}

enum ProductCategory: String {
    case documents = "Documents"
    case photos = "Photos"
    case videos = "Videos"
    case free = "Free"
}
