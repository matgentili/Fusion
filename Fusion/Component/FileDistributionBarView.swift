//
//  FileDistributionBarView.swift
//  Fusion
//
//  Created by Matteo Gentili on 18/12/23.
//

import SwiftUI

struct FileDistributionBarView: View {
    var items: [Item]
    
    var percentage: Double {
        let space = items.reduce(0.0) { $0 + ($1.size ?? 0.0) }.byteToGB()
        return space
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 10)
                    .opacity(0.3)
                    .foregroundColor(Color.gray)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.percentage) * geometry.size.width, geometry.size.width), height: 10)
                    .foregroundColor(items[0].type?.getPrimaryColor() ?? .green)
            }
            .cornerRadius(5)
        }
        .frame(height: 50)
    }
}

#Preview {
    FileDistributionBarView(items: [Item.preview, Item.preview])
}
