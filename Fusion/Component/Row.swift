//
//  Row.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import SwiftUI
import SirioKitIOS

struct Row: View {
    var item: Item
    
    var body: some View {
        HStack(spacing: 0) {
            iconView.padding()
            
            VStack(alignment: .leading, spacing: 0){
                SirioText(text: "\(item.name)", typography: .helper_text_xs_400)
                SirioText(text: "Peso: \(item.size?.toMB() ?? "") - Data: \(item.date ?? "")", typography: .helper_text_xs_400)
                SirioText(text: "Email: \(item.emailOwner ?? "")", typography: .helper_text_xs_400)

            }
            Spacer()
        }
        .clipShape(Rectangle())
    }
    
    private var iconView: some View {
        return HStack {
            if let type = item.type {
                VStack {
                    SirioIcon(data: .init(icon: type.getIcon()))
                        .frame(width: 20, height: 20)
                        .foregroundStyle(type.getPrimaryColor())
                }
                .frame(width: 44, height: 44)
                .background(type.getSecondaryColor())
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}

#Preview {
    Row(item: Item.preview)
}
