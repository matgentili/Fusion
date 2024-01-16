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
    @EnvironmentObject var coordinator: Coordinator<Router>
    
    @StateObject var vm: HomeViewModel = HomeViewModel()
    
    @State private var selectedImage: UIImage?
    @State private var base64: String? // Viene riempita sia da picker image che da picker file
    @State private var data: Data?
    
    
    private var leftItem: AppNavigationItemData {
        return AppNavigationItemData(icon: .bars, action: {
            
        })
    }
    
    private var profile: AppNavigationItemData {
        return AppNavigationItemData(icon: .user, action: {
            coordinator.loginEnv.logout {
                self.coordinator.pop()
            }
        })
    }
    
    private var legendaView: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(vm.chartProducts) { product in
                HStack {
                    Circle()
                        .fill(product.primaryColor)
                        .frame(width: 8, height: 8)
                    
                    SirioText(text: product.category.rawValue, typography: .label_md_400)
                    
                    Spacer()
                    
                    SirioText(text: "\(product.percent)%", typography: .label_md_600)
                    
                }
            }
            //SirioText(text: "Total space: \(coordinator.loginEnv.profile?.space_GB ?? 1) GB", typography: .label_md_400)
            
        }
    }
    
    private var carouselView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                
                CardView(icon: .camera,
                         title: "Photos",
                         items: "\(vm.itemsPhoto.count) items",
                         iconFolder: .lock,
                         folder: "Private Folder",
                         backgroundColor: Color.colorPhotosSecondary,
                         iconColor: Color.colorPhotosPrimary)
                .onTapGesture {
                    if !vm.itemsPhoto.isEmpty {
                        self.coordinator.show(.detail(vm: vm, type: .photo))
                    }
                }
                
                CardView(icon: .playCircle,
                         title: "Videos",
                         items: "\(vm.itemsVideo.count) items",
                         iconFolder: .lock,
                         folder: "Private Folder",
                         backgroundColor: Color.colorVideosSecondary,
                         iconColor: Color.colorVideosPrimary)
                .onTapGesture {
                    if !vm.itemsVideo.isEmpty {
                        self.coordinator.show(.detail(vm: vm, type: .video))
                    }
                }
                CardView(icon: .filePdf,
                         title: "Documents",
                         items: "\(vm.itemsDocument.count) items",
                         iconFolder: .lock,
                         folder: "Public Folder",
                         backgroundColor: Color.colorDocumentsSecondary,
                         iconColor: Color.colorDocumentsPrimary)
                .onTapGesture {
                    if !vm.itemsDocument.isEmpty {
                        self.coordinator.show(.detail(vm: vm, type: .document))
                    }
                }
            }
        }
    }
    
    var body: some View {
        AppNavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    SirioText(text: "My Files", typography: .label_md_600)
                    
                    HStack {
                        InteractiveDonutView(products: $vm.chartProducts)
                            .frame(width: 160, height: 160)
                            .padding(.trailing)
                        
                        Spacer()
                        
                        legendaView
                    }
                    .padding(.vertical)
                    
                    carouselView
                    
                    if !vm.itemsShared.isEmpty {
                        SirioText(text: "Shared Files", typography: .label_md_700)
                            .padding(.top, 16)
                            .padding(.bottom)
                        
                        SharedCardView(icon: .folder,
                                       title: "Shared",
                                       items: "\(vm.itemsShared.count) items",
                                       iconFolder: .lockOpen,
                                       folder: "Public Folder",
                                       backgroundColor: Color.colorSharedSecondary,
                                       iconColor: Color.colorSharedPrimary,
                                       isPrivate: false)
                        .onTapGesture {
                            if !vm.itemsShared.isEmpty {
                               // self.coordinator.show(.shared(vm: vm))
                                self.coordinator.show(.detail(vm: vm, type: .shared))
                            }
                        }
                    }
                }
            }
            .overlay(alignment: .bottomTrailing, content: {
                ButtonUploader(vm: vm)
            })
            .padding()
            .setAppNavigationBarItems(leftItem: leftItem, rightItems: [profile])
        }
        .progressBarView(isPresented: $vm.isLoading)
    }
}

#Preview {
    HomeScreen()
}
extension URL {
    func getExtension() -> String {
        print("L'estensione del file è: \(self.pathExtension)")
        return self.pathExtension
    }
}


//                        ForEach(vm.itemsPhoto){ item in
//                            Row(item: item)
//                                .onTapGesture {
//
//                                    Task {
//                                        try await vm.getPhoto(item: item)
//                                    }
//                                    Task {
//                                        var updatedItem = item
//                                        updatedItem.addSharedUser(email: "matteogentili20@gmail.com")
//                                        do {
//                                            try await vm.updateItem(item: item, updatedItem: updatedItem)
//                                        } catch {
//                                            print("Errore durante l'aggiornamento dell'elemento: \(error)")
//                                        }
//                                    }




//                    SirioText(text: "Shared Files", typography: .label_md_700)
//                    if vm.itemsPhotoShared.isEmpty {
//                        SirioText(text: "Nessun Shared File", typography: .label_md_600)
//                    } else {
//                        ForEach(vm.itemsPhotoShared){ item in
//                            Row(item: item)
//                                .onTapGesture {
//                                    Task {
//                                        try? await vm.getPhoto(item: item)
//                                    }
//                                    //vm.update(item: item)
//                                }
//                        }
//                    }


//                    if !vm.retrievedPhotos.isEmpty {
//                        ScrollView(.horizontal) {
//                            HStack {
//                                ForEach(vm.retrievedPhotos, id: \.self){ image in
//                                    Image(uiImage: image)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 100, height: 100)
//                                }
//                                .id(UUID())
//                            }
//                        }
//                    }
