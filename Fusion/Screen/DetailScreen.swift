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
    @ObservedObject var vm: UploaderViewModel
    var type: ItemType
    
    init(vm: UploaderViewModel, type: ItemType) {
        self.vm = vm
        self.type = type
    }
    
    private func filteredItems() -> [Product] {
        return vm.chartProducts.filter { $0.category == .photos || $0.category == .videos || $0.category == .documents }
    }
    
    var freeSpace: String {
        let items = filteredItems()
        guard let firstItem = items.first, !items.isEmpty else {
            return "nd"
        }
        let totalSpace = firstItem.totalSpaceByte.byteToGB()
        let space = items.reduce(0.0) { $0 + $1.spaceUsedByte }.byteToGB()
        return String(format: "%.2f", totalSpace - space)
    }
    
    var usedSpace: String {
        let space = filteredItems().reduce(0.0) { $0 + $1.spaceUsedByte }.byteToGB()
        return String(format: "%.2f", space)
    }
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    SirioIcon(data: .init(icon: .angleLeft))
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.white)
                        .onTapGesture {
                            coordinator.pop()
                        }
                    
                    Spacer()
                    
                    SirioIcon(data: .init(icon: .user))
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 20)
                
                HStack(spacing: 20) {
                    SirioIcon(data: .init(icon: type.getIcon()))
                        .frame(width: 24, height: 24)
                        .foregroundStyle(type.getPrimaryColor())
                    
                    MGText(text: type.rawValue, textColor: .white, fontType: .semibold, fontSize: 28)
                    
                    Spacer()
                    
                    SirioIcon(data: .init(icon: .paw))
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.white)
                }
                
                HStack {
                    MGText(text: usedSpace, textColor: .white, fontType: .semibold, fontSize: 40)
                    VStack(alignment: .leading, spacing: 0) {
                        MGText(text: "GB", textColor: .gray, fontType: .regular, fontSize: 14)
                        MGText(text: "Used", textColor: .gray, fontType: .regular, fontSize: 14)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        MGText(text: freeSpace, textColor: .gray, fontType: .regular, fontSize: 14)
                        MGText(text: "Free", textColor: .gray, fontType: .regular, fontSize: 14)
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .background(Color.init(hex: "272a3b"))
            .roundedCorner(30, corners: [.bottomLeft, .bottomRight])
            .overlay(alignment: .top, content: {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.init(hex: "272a3b"))
                        .frame(height: geometry.safeAreaInsets.top)
                        .ignoresSafeArea(.all, edges: .top)
                }
            })
            
            ScrollView {
                MGText(text: "\(type.rawValue) Files", textColor: .gray, fontType: .regular, fontSize: 18)
                
                
            }
        }
    }
}

#Preview {
    DetailScreen(vm: .init(), type: .photo)
}
