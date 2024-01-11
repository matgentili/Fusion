//
//  MGText.swift
//  Fusion
//
//  Created by Matteo Gentili on 07/01/24.
//

import SwiftUI
import SirioKitIOS

struct MGText: View {
    enum FontType {
        case regular
        case bold
        case semibold
        
        var fontName: String {
            switch self {
            case .regular:
                return "Titillium Web Regular"
            case .bold:
                return "Titillium Web Bold"
            case .semibold:
                return "Titillium Web SemiBold"
            }
        }
    }
    
    var text: String
    var textColor: Color
    var fontType: FontType
    var fontSize: Double
    
    var body: some View {
        Text(text)
            .foregroundColor(textColor)
            .font(.custom(fontType.fontName, size: fontSize))
            .font(.system(size: fontSize))
    }
}

#Preview {
    MGText(text: "Hello, Custom Text!", textColor: .blue, fontType: .bold, fontSize: 20)
}
