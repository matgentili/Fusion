//
//  CardView.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import SwiftUI
import SirioKitIOS

struct CardView: View {
    var icon: AwesomeIcon
    var title: String
    var items: String
    var iconFolder: AwesomeIcon
    var folder: String
    var backgroundColor: Color
    var iconColor: Color
    
    var body: some View {
        VStack {
            HStack {
                SirioIcon(data: .init(icon: icon))
                    .foregroundStyle(iconColor)
                    .frame(width: 36, height: 36)
                Spacer()
            }
            
            Spacer()
            
            HStack {
                SirioText(text: title, typography: .label_md_700)
                Spacer()
            }
            
            HStack {
                SirioText(text: items, typography: .label_md_400)
                Spacer()
            }
            
            HStack {
                SirioIcon(data: .init(icon: iconFolder))
                    .foregroundStyle(iconColor)
                    .frame(width: 16, height: 16)
                SirioText(text: folder, typography: .helper_text_xs_400)
                Spacer()
            }
        }
        .padding(20)
        .frame(width: 200, height: 280)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CardView(icon: .folder, title: "Photos", items: "682 items", iconFolder: .lock, folder: "Private Folder", backgroundColor: Color.init(hex: "c3f3e6"), iconColor: Color.init(hex: "00ce99"))
}
