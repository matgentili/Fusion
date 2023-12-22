//
//  DetailScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import SwiftUI
import SirioKitIOS

struct DetailScreen: View {
    var category: ProductCategory
    
    var body: some View {
        AppNavigationView {
            SirioIcon(data: .init(icon: .video))
            
        }
    }
}

#Preview {
    DetailScreen(category: .media)
}
