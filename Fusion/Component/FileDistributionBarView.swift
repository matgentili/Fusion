//
//  FileDistributionBarView.swift
//  Fusion
//
//  Created by Matteo Gentili on 18/12/23.
//

import SwiftUI

struct FileDistributionBarView: View {
    var documentPercentage: CGFloat
    var photoPercentage: CGFloat
    var videoPercentage: CGFloat
   
    var body: some View {
        VStack {
            Spacer()
            
            GeometryReader { geometry in
                let lenght = geometry.size.width
                HStack(spacing: 0) {
//                    ForEach(Product.preview){
//                    da mettere
//                    }
                    Rectangle()
                        .frame(width: documentPercentage * lenght, height: 20)
                        .foregroundColor(Color.colorDocumentsPrimary) // Colore per i documenti
                        .roundedCorner(10, corners: [.topLeft, .bottomLeft]) // Stonda solo il lato sinistro

                    Rectangle()
                        .frame(width: photoPercentage * lenght, height: 20)
                        .foregroundColor(Color.colorPhotosPrimary) // Colore per le immagini
                    
                    Rectangle()
                        .frame(width: videoPercentage * lenght, height: 20)
                        .foregroundColor(Color.colorVideosPrimary) // Colore per i video
                        .roundedCorner(10, corners: [.topRight, .bottomRight]) // Stonda solo il lato destro
                }
            }
            
            
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    FileDistributionBarView(documentPercentage: 0.43, photoPercentage: 0.35, videoPercentage: 0.22)
}
