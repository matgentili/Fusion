//
//  HomeScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI
import SirioKitIOS
import Charts

struct HomeScreen: View {
    
    private var leftItem: AppNavigationItemData {
        return AppNavigationItemData(icon: .bars, action: {
            
        })
    }
    
    private var profile: AppNavigationItemData {
        return AppNavigationItemData(icon: .user, action: {
            
        })
    }
    
    @State var progress1: Double = 0.0
    @State var progress2: Double = 0.0
    @State var progress3: Double = 0.0
    
    var body: some View {
        AppNavigationView {
            VStack(alignment: .leading) {
                SirioText(text: "My Files", typography: .label_md_600)
                
                FileDistributionBarView(documentPercentage: 0.43, photoPercentage: 0.35, videoPercentage: 0.22)
                ZStack {
                    Circle()
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    Circle()
                        .trim(from: 0.0, to: progress1)
                        .stroke(Color.colorDocuments, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90)) // Per far iniziare il progresso da 0 gradi
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
                    
                    
                    Circle()
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 80, height: 80)
                    Circle()
                        .trim(from: 0.0, to: progress2)
                        .stroke(Color.colorPhotos, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90)) // Per far iniziare il progresso da 0 gradi
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .stroke(Color.gray, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 60, height: 60)
                    Circle()
                        .trim(from: 0.0, to: progress3)
                        .stroke(Color.colorMedia, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90)) // Per far iniziare il progresso da 0 gradi
                        .frame(width: 60, height: 60)
                }
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.0) // Modifica la durata desiderata (in secondi)
                    ) {
                        self.progress1 = 0.43
                        self.progress2 = 0.35
                        self.progress3 = 0.22
                    }
                }
                
                .padding(20)
                SectorChartExample()
                HStack {
                    Circle()
                        .fill(Color.colorDocuments)
                        .frame(width: 8, height: 8)
                    
                    SirioText(text: "Documents", typography: .label_md_400)
                    
                    Circle()
                        .fill(Color.colorPhotos)
                        .frame(width: 8, height: 8)
                    
                    SirioText(text: "Photos", typography: .label_md_400)
                    
                    Circle()
                        .fill(Color.colorMedia)
                        .frame(width: 8, height: 8)
                    
                    SirioText(text: "Media", typography: .label_md_400)
                    
                    //Spacer()
                }
            }
            .padding()
            .setAppNavigationBarItems(leftItem: leftItem, rightItems: [profile])
        }
    }
}

#Preview {
    HomeScreen()
}

struct Product: Identifiable {
    let id = UUID()
    let title: String
    let revenue: Double
    let color: Color
}


struct SectorChartExample: View {
    @State private var products: [Product] = [
        .init(title: "Documents", revenue: 0.43, color: Color.colorDocuments),
        .init(title: "Photos", revenue: 0.35, color: Color.colorPhotos),
        .init(title: "Media", revenue: 0.22, color: Color.colorMedia)
    ]
    
    private let colors: [Color] = [.yellow, .red, .blue]
    
    var body: some View {
        Chart(products) { product in
            SectorMark(
                angle: .value(
                    Text(verbatim: product.title),
                    product.revenue
                )
            )
            
            .foregroundStyle(colors[products.firstIndex(where: { $0.title == product.title }) ?? 0])
            .foregroundStyle(
                by: .value(
                    Text(verbatim: product.title),
                    product.title
                )
            )
        }
        .frame(width: 180, height: 180)
    }
}
