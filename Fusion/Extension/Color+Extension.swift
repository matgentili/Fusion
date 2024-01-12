//
//  Color+Extension.swift
//  Fusion
//
//  Created by Matteo Gentili on 18/12/23.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static var test = Color(hex: "615aff")
    // Photos
    static var colorPhotosPrimary = Color(hex: "00ce99")
    static var colorPhotosSecondary = Color(hex: "c3f3e6")
    // Videos
    static var colorVideosPrimary = Color(hex: "f4b800")
    static var colorVideosSecondary = Color(hex: "fbefc1")
    // Documents
    static var colorDocumentsPrimary = Color(hex: "5452ff")
    static var colorDocumentsSecondary = Color(hex: "d6d4fb")
    
    // Shared
    static var colorSharedPrimary = Color(hex: "ff6f61") // Tonalità di rosso/arancione
    static var colorSharedSecondary = Color(hex: "ffd3cc")
}
