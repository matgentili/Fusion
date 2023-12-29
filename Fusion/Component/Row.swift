//
//  Row.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import SwiftUI
import SirioKitIOS

struct Row: View {
    var product: Product
    
    var body: some View {
        HStack {
            iconView.padding()
            
            VStack(alignment: .leading, spacing: 0){
                SirioText(text: "Name", typography: .label_md_600)
                SirioText(text: "Peso - Data", typography: .label_md_400)
            }
            
            Spacer()
        }
    }
    
    private var iconView: some View {
        return HStack {
            VStack {
                SirioIcon(data: .init(icon: icon!))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(product.primaryColor)
            }
            .frame(width: 48, height: 48)
            .background(product.secondaryColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    
    var icon: AwesomeIcon? {
        switch product.category {
        case .documents:
            return .folder
        case .photos:
            return .photoVideo
        case .videos:
            return .fileVideo
        case .free:
            return nil
        }
    }
}

#Preview {
    Row(product: Product.preview[0])
}
