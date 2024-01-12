//
//  ButtonUploader.swift
//  Fusion
//
//  Created by Matteo Gentili on 12/01/24.
//

import SwiftUI

struct ButtonUploader: View {
    
    var body: some View {
        Button(action: {
            shouldPresentActionSheet.toggle()
        }, label: {
            Image(systemName: "plus.circle.fill") // You can use any system icon
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.green)
                .background(Color.white)
                .clipShape(Circle())
        })
    }
}

#Preview {
    ButtonUploader()
}
