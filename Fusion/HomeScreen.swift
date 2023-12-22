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
            ScrollView {
                VStack(alignment: .leading) {
                    SirioText(text: "My Files", typography: .label_md_600)
                    
                    HStack {
                        InteractiveDonutView(products: Product.preview)
                            .frame(width: 160, height: 160)
                            .padding(.trailing)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Product.preview) { product in
                                HStack {
                                    Circle()
                                        .fill(product.color)
                                        .frame(width: 8, height: 8)
                                    
                                    SirioText(text: product.category, typography: .label_md_400)
                                    
                                    Spacer()
                                    
                                    SirioText(text: "\(product.percent*100)%", typography: .label_md_600)

                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    
                }
                
                VStack(alignment: .leading) {
                    SirioIcon(data: .init(icon: .folder))
                        .foregroundStyle(Color.init(hex: "00ce99"))
                        .frame(width: 36, height: 36)
                        .padding(.bottom, 60)
                    
                    Spacer()
                    
                    SirioText(text: "Photos", typography: .label_md_700)
                    
                    SirioText(text: "682 items", typography: .label_md_400)
                    
                            Text("Contenuto del testo 1.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.bottom, 10)

                            Text("Titolo 2")
                                .font(.title)
                                .padding(.bottom, 5)

                        }
                        .padding(20)
                        .frame(width: 200, height: 280)
                        .background(Color.init(hex: "c3f3e6"))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            .padding()
            .setAppNavigationBarItems(leftItem: leftItem, rightItems: [profile])
        }
    }
}

#Preview {
    HomeScreen()
}
