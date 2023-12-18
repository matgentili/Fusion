//
//  HomeScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI
import SirioKitIOS

struct HomeScreen: View {
    
    private var leftItem: AppNavigationItemData {
        return AppNavigationItemData(icon: .bars, action: {
            
        })
    }
    
    private var profile: AppNavigationItemData {
        return AppNavigationItemData(icon: .user, action: {
            
        })
    }
    var body: some View {
//        AppNavigationView {
//            HStack {
//                Spacer()
//                
//                SirioText(text: "", typography: .label_md_700)
//                    .foregroundColor(Color.red)
//                    .padding()
//                Spacer()
//            }
//        }
        AppNavigationView {
            VStack(alignment: .leading) {
                SirioText(text: "My Files", typography: .label_md_600)
                
                FileDistributionBarView(documentPercentage: 0.43, photoPercentage: 0.35, videoPercentage: 0.22)
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
