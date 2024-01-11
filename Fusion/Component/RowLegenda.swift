//
//  RowLegenda.swift
//  Fusion
//
//  Created by Matteo Gentili on 10/01/24.
//

import SwiftUI

struct RowLegenda: View {
    var product: Product
    
    var body: some View {
        HStack {
            Circle()
                .fill(product.primaryColor)
                .frame(width: 8, height: 8)
            
            MGText(text: product.category.rawValue, textColor: .black, fontType: .regular, fontSize: 14)

            
            Spacer()
            
            MGText(text: "\(product.percent)%", textColor: .black, fontType: .regular, fontSize: 14)

        }
    }
}
//
//#Preview {
//    RowLegenda()
//}
