//
//  Product.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import Foundation
import UIKit
import SwiftUI

struct Product: Identifiable, Equatable {
    var category: String
    var percent: Double
    var color: Color
    var id = UUID()
    
    static var preview: [Product] =  [
        .init(category: "Documents", percent: 0.20, color: Color.colorDocuments),
        .init(category: "Photos", percent: 0.30, color: Color.colorPhotos),
        .init(category: "Media", percent: 0.18, color: Color.colorMedia),
        .init(category: "Free", percent: 0.32, color: Color.gray.opacity(0.8))
    ]
}

