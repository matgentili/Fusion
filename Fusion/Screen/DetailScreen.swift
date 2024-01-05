//
//  DetailScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import SwiftUI
import SirioKitIOS

struct DetailScreen: View {
    @EnvironmentObject var coordinator: Coordinator<Router>
    var type: ItemType
    
    private var leftItem: AppNavigationItemData {
        return AppNavigationItemData(icon: .angleLeft, action: {
            coordinator.pop()
        })
    }
    
    private var profile: AppNavigationItemData {
        return AppNavigationItemData(icon: .user, action: {
            
        })
    }
    
    var body: some View {

        AppNavigationView {
            VStack {
                HStack {
                    SirioIcon(data: .init(icon: type.getIcon()))
                        .frame(width: 30, height: 30)
                        .foregroundStyle(type.getPrimaryColor())
                    
                    SirioText(text: type.rawValue, typography: .label_md_600)
                }
                
                ScrollView {
                    
                }
            }
            .setAppNavigationBarItems(leftItem: leftItem, rightItems: [profile])
        }
        //.progressBarView(isPresented: $uploaderVM.isLoading)
    }
}

#Preview {
    DetailScreen(type: .photos)
}
