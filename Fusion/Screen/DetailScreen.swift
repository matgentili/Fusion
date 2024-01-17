//
//  DetailScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import SwiftUI
import SirioKitIOS
import ImageViewer

enum ActionMode {
    case upload, share, delete
}

struct DetailScreen: View {
    @EnvironmentObject var coordinator: Coordinator<Router>
    @ObservedObject var vm: HomeViewModel
    var type: ItemType
    @State var mode: ActionMode = .upload
    @State var isSelectionModeEnabled: Bool = false
    @State var itemsToDoAction: [Item] = []
    @State var showImageViewer: Bool = false
    @State var image: Image?
    
    var items: [Item] {
        switch type {
        case .document:
            return vm.itemsDocument
        case .photo:
            return vm.itemsPhoto
        case .video:
            return vm.itemsVideo
        case .shared:
            return vm.itemsShared
        }
    }
    
    init(vm: HomeViewModel, type: ItemType) {
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
    var usedSpace: (String, String) {
        var used = ("","")
        let spaceByte = items.reduce(0.0) { $0 + ($1.size ?? 0.0) }
        let spaceMB = spaceByte.byteToMB()
        let spaceGB = spaceByte.byteToGB()
            //.byteToMB()  //byteToGB()
        if spaceMB > 100 {
            used.0 = "\(spaceGB)"
            used.1 = "GB"
        } else {
            used.0 = "\(spaceMB)"
            used.1 = "MB"
        }
        return used
    }
    
    private func getSpace(value: Double) -> String {
        if value > 0.0 {
            return String(format: "%.2f", value)
        }
        return "0"
    }
    
    private var spaceView: some View {
        HStack {
            MGText(text: usedSpace.0, textColor: .white, fontType: .semibold, fontSize: 40)
            VStack(alignment: .leading, spacing: 0) {
                MGText(text: usedSpace.1, textColor: .gray, fontType: .regular, fontSize: 14)
                MGText(text: "Used", textColor: .gray, fontType: .regular, fontSize: 14)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 0) {
                MGText(text: "\(getSpace(value: freeSpace)) GB", textColor: .gray, fontType: .regular, fontSize: 14)
                MGText(text: "Free", textColor: .gray, fontType: .regular, fontSize: 14)
            }
        }
        .padding(.bottom, 20)
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
                    
                    if isSelectionModeEnabled { // Se è attiva allora c'è il bottone X per chiudere la modalità
                        Button(action: {
                            self.isSelectionModeEnabled = false
                            
                        }, label: {
                            SirioIcon(data: .init(icon: .times))
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.white)
                                .onTapGesture {
                                    withAnimation {
                                        self.itemsToDoAction = []
                                        self.mode = .upload
                                        self.isSelectionModeEnabled = false
                                    }
                                }
                        })
                    } else {
                        Menu { // Menu per scegliere l'azione
                            Button("Delete", action: {
                                self.mode = .delete
                                self.isSelectionModeEnabled.toggle()
                            })
                            if type != .shared {
                                Button("Share", action: {
                                    self.mode = .share
                                    self.isSelectionModeEnabled.toggle()
                                })
                            }
                        } label: {
                            Button(action: {
                                
                            }, label: {
                                SirioIcon(data: .init(icon: .ellipsisH))
                                    .frame(width: 24, height: 24)
                                    .foregroundStyle(.white)
                            })
                        }
                    }
                }
                .padding(.bottom, type == .shared ? 20 : 0)
                
                if type != .shared {
                    spaceView
                    FileDistributionBarView(items: items, type: type)
                }
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
                }
                .padding(.horizontal)
                
                ScrollView {
                    ForEach(items){ item in
                        Row(item: item, isSelectionModeEnabled: $isSelectionModeEnabled, onSelectChange: {
                            isSelected in
                            if isSelected {
                                itemsToDoAction.append(item)
                            } else {
                                if let index = itemsToDoAction.firstIndex(where: { $0 == item }) {
                                    itemsToDoAction.remove(at: index)
                                }
                            }
                        }, onTapGesture: {
                            Task {
                                self.image = try? await vm.getPhoto(item: item)
                                showImageViewer = true
                            }
                        })
                    }
                }
            }
            Spacer()
        }
        .overlay(alignment: .bottomTrailing, content: {
            switch mode {
            case .upload:
                ButtonUploader(vm: vm)
                    .padding()
            case .share:
                SharedButton(vm: vm, itemsToShare: $itemsToDoAction, isSelectionModeEnabled: $isSelectionModeEnabled, mode: $mode)
                    .padding()
            case .delete:
                DeleteButton(vm: vm, itemsToDelete: $itemsToDoAction, isSelectionModeEnabled: $isSelectionModeEnabled, type: type, mode: $mode)
                    .padding()
            }
        })
        .overlay(content: {
            ImageViewer(image: self.$image, viewerShown: self.$showImageViewer)
        })
        .progressBarView(isPresented: $vm.isLoading)
    }
}

#Preview {
    DetailScreen(vm: .init(), type: .photo)
}
