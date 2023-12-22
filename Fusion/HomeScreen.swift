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
                                        .fill(product.primaryColor)
                                        .frame(width: 8, height: 8)
                                    
                                    SirioText(text: product.category.rawValue, typography: .label_md_400)
                                    
                                    Spacer()
                                    
                                    SirioText(text: "\(product.percent*100)%", typography: .label_md_600)
                                    
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            CardView(icon: .folder,
                                     title: "Photos",
                                     items: "682 items",
                                     iconFolder: .lock,
                                     folder: "Private Folder",
                                     backgroundColor: Color.init(hex: "c3f3e6"),
                                     iconColor: Color.init(hex: "00ce99"))
                            
                            CardView(icon: .playCircle,
                                     title: "Media",
                                     items: "78 items",
                                     iconFolder: .lockOpen,
                                     folder: "Public Folder",
                                     backgroundColor: Color.init(hex: "fbefc1"),
                                     iconColor: Color.init(hex: "f4b800"))
                        }
                    }
                    
                    SirioText(text: "Latest Files", typography: .label_md_700)
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
