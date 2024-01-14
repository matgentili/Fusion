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
    @State var isSelectionModeEnabled: Bool = false
    @State var itemsToShare: [Item] = []
    
    var items: [Item] {
        switch type {
        case .document:
            return vm.itemsDocument
        case .photo:
            return vm.itemsPhoto
        case .video:
            return vm.itemsVideo
        }
    }
    
    init(vm: UploaderViewModel, type: ItemType) {
        self.vm = vm
        self.type = type
    }
    
    private func filteredItems() -> [Product] {
        return vm.chartProducts.filter { $0.category == .photos || $0.category == .videos || $0.category == .documents }
    }
    
    // Lo spazio libero su cloud
    var freeSpace: Double {
        let items = filteredItems()
        guard let firstItem = items.first, !items.isEmpty else {
            return 0.0
        }
        let totalSpace = firstItem.totalSpaceByte.byteToGB()
        let space = items.reduce(0.0) { $0 + $1.spaceUsedByte }.byteToGB()
        return totalSpace - space
    }
    
    // Lo spazio usato per gli item in questo screen
    var usedSpace: Double {
        let space = items.reduce(0.0) { $0 + ($1.size ?? 0.0) }.byteToGB()
        return space
    }
    
    private func getSpace(value: Double) -> String {
        if value > 0.0 {
            return String(format: "%.2f", value)
        }
        return "nd"
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
                    
//                    SirioIcon(data: .init(icon: .paw))
//                        .frame(width: 30, height: 30)
//                        .foregroundStyle(Color.white)
                }
                
                HStack {
                    MGText(text: getSpace(value: usedSpace), textColor: .white, fontType: .semibold, fontSize: 40)
                    VStack(alignment: .leading, spacing: 0) {
                        MGText(text: "GB", textColor: .gray, fontType: .regular, fontSize: 14)
                        MGText(text: "Used", textColor: .gray, fontType: .regular, fontSize: 14)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 0) {
                        MGText(text: "\(getSpace(value: freeSpace)) GB", textColor: .gray, fontType: .regular, fontSize: 14)
                        MGText(text: "Free", textColor: .gray, fontType: .regular, fontSize: 14)
                    }
                }
                .padding(.bottom, 20)
                
                
                
                
                
                FileDistributionBarView(items: items, type: type)
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
            
            if items.isEmpty {
                MGText(text: "Nessun file", textColor: .black, fontType: .regular, fontSize: 14)
                    .padding()
            } else {
                HStack {
                    MGText(text: "\(type.rawValue) Files", textColor: .black, fontType: .bold, fontSize: 18)
                    
                    Spacer()
                    
                    if isSelectionModeEnabled {
                        Button(action: {
                            self.isSelectionModeEnabled = false
                            
                        }, label: {
                            SirioIcon(data: .init(icon: .times))
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.black)
                        })
                    } else {
                        Menu {
                            Button("Select", action: {
                                self.isSelectionModeEnabled.toggle()
                            })
                        } label: {
                            Button(action: {
                                
                            }, label: {
                                SirioIcon(data: .init(icon: .ellipsisH))
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(.black)
                            })
                            
                        }
                    }
                }
                .padding(.horizontal)
                
                ScrollView {
                    ForEach(items){ item in
                        Row(item: item, isSelectionModeEnabled: $isSelectionModeEnabled, onSelectChange: {
                            isSelected in
                            if isSelected {
                                itemsToShare.append(item)
                            } else {
                                if let index = itemsToShare.firstIndex(where: { $0 == item }) {
                                    itemsToShare.remove(at: index)
                                }
                            }
                        })
                        .onTapGesture {
                            Task {
                                try? await vm.getPhoto(item: item)
                            }
                            //uploaderVM.update(item: item)
                        }
                    }
                }
            }
            Spacer()
        }
        .overlay(alignment: .bottomTrailing, content: {
            if isSelectionModeEnabled {
                SharedButton(vm: vm, itemsToShare: $itemsToShare, isSelectionModeEnabled: $isSelectionModeEnabled)
                    .padding()
            } else {
                ButtonUploader(vm: vm)
                    .padding()
            }
            
        })
        .progressBarView(isPresented: $vm.isLoading)
    }
}

#Preview {
    DetailScreen(vm: .init(), type: .photo)
}
