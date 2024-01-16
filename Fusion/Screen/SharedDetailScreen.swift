//
//  SharedDetailScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 12/01/24.
//

import SwiftUI
import SirioKitIOS

struct SharedDetailScreen: View {
    @EnvironmentObject var coordinator: Coordinator<Router>
    @ObservedObject var vm: HomeViewModel
 
    init(vm: HomeViewModel) {
        self.vm = vm
    }
    
    @State var isSelectionModeEnabled: Bool = false
    @State var itemsToDelete: [Item] = []

    var type = ItemType.shared

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
//                
//                HStack {
//                    MGText(text: getSpace(value: usedSpace), textColor: .white, fontType: .semibold, fontSize: 40)
//                    VStack(alignment: .leading, spacing: 0) {
//                        MGText(text: "GB", textColor: .gray, fontType: .regular, fontSize: 14)
//                        MGText(text: "Used", textColor: .gray, fontType: .regular, fontSize: 14)
//                    }
//                    
//                    Spacer()
//                    
//                    VStack(alignment: .trailing, spacing: 0) {
//                        MGText(text: "\(getSpace(value: freeSpace)) GB", textColor: .gray, fontType: .regular, fontSize: 14)
//                        MGText(text: "Free", textColor: .gray, fontType: .regular, fontSize: 14)
//                    }
//                }
//                .padding(.bottom, 20)
//
//                FileDistributionBarView(items: items, type: type)
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
            
            if vm.itemsShared.isEmpty {
                MGText(text: "Nessun file", textColor: .black, fontType: .regular, fontSize: 14)
                    .padding()
            } else {
                HStack {
                    MGText(text: "Shared Files", textColor: .black, fontType: .bold, fontSize: 18)
                    
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
                            Button("Delete", action: {
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
                    ForEach(vm.itemsShared){ item in
                        Row(item: item, isSelectionModeEnabled: $isSelectionModeEnabled, onSelectChange: {
                            isSelected in
                            if isSelected {
                                itemsToDelete.append(item)
                            } else {
                                if let index = itemsToDelete.firstIndex(where: { $0 == item }) {
                                    itemsToDelete.remove(at: index)
                                }
                            }
                        })
                        .onTapGesture {
                            Task {
                                try? await vm.getPhoto(item: item)
                            }
                            //vm.update(item: item)
                        }
                    }
                }
            }
            Spacer()
        }
        .overlay(alignment: .bottomTrailing, content: {
            if isSelectionModeEnabled {
//                SharedButton(vm: vm, itemsToShare: $itemsToShare, isSelectionModeEnabled: $isSelectionModeEnabled)
//                    .padding()
            } else {
                ButtonUploader(vm: vm)
                    .padding()
            }
            
        })
        .progressBarView(isPresented: $vm.isLoading)
    }
}

#Preview {
    SharedDetailScreen(vm: HomeViewModel())
}
