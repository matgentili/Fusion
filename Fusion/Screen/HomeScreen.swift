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
    
    @StateObject var uploaderVM: UploaderViewModel = UploaderViewModel()
    @StateObject var sharedVM: SharedItemsViewModel = SharedItemsViewModel()
    
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
            ForEach(uploaderVM.chartProducts) { product in
                HStack {
                    Circle()
                        .fill(product.primaryColor)
                        .frame(width: 8, height: 8)
                    
                    SirioText(text: product.category.rawValue, typography: .label_md_400)
                    
                    Spacer()
                    
                    SirioText(text: "\(product.percent)%", typography: .label_md_600)
                    
                }
            }
            SirioText(text: "\(String(describing: coordinator.loginEnv.profile?.space_GB))", typography: .label_md_400)
            
        }
    }
    
    private var carouselView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                
                CardView(icon: .camera,
                         title: "Photos",
                         items: "\(uploaderVM.itemsPhoto.count) items",
                         iconFolder: .lock,
                         folder: "Private Folder",
                         backgroundColor: Color.colorPhotosSecondary,
                         iconColor: Color.colorPhotosPrimary)
                .onTapGesture {
                    if !uploaderVM.itemsPhoto.isEmpty {
                        self.coordinator.show(.detail(vm: uploaderVM, type: .photo))
                    }
                }
                
                CardView(icon: .playCircle,
                         title: "Videos",
                         items: "\(uploaderVM.itemsVideo.count) items",
                         iconFolder: .lock,
                         folder: "Private Folder",
                         backgroundColor: Color.colorVideosSecondary,
                         iconColor: Color.colorVideosPrimary)
                .onTapGesture {
                    if !uploaderVM.itemsVideo.isEmpty {
                        self.coordinator.show(.detail(vm: uploaderVM, type: .video))
                    }
                }
                CardView(icon: .filePdf,
                         title: "Documents",
                         items: "\(uploaderVM.itemsDocument.count) items",
                         iconFolder: .lock,
                         folder: "Public Folder",
                         backgroundColor: Color.colorDocumentsSecondary,
                         iconColor: Color.colorDocumentsPrimary)
                .onTapGesture {
                    if !uploaderVM.itemsDocument.isEmpty {
                        self.coordinator.show(.detail(vm: uploaderVM, type: .document))
                    }
                }
            }
        }
    }
    
    var body: some View {
        AppNavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SirioText(text: "My Files", typography: .label_md_600)
                    
                    HStack {
                        InteractiveDonutView(products: $uploaderVM.chartProducts)
                            .frame(width: 160, height: 160)
                            .padding(.trailing)
                        
                        Spacer()
                        
                        legendaView
                    }
                    .padding(.vertical)
                    
                    carouselView
                    
                    SirioText(text: "Shared Files", typography: .label_md_700)
                        .padding(.top, 16)
                        .padding(.bottom)
                    
                    if uploaderVM.itemsPhoto.isEmpty {
                        SirioText(text: "Nessun Own File", typography: .label_md_600)
                    } else {
                        
                        SharedCardView(icon: .folder,
                                       title: "Shared",
                                       items: "\(sharedVM.items.count) items",
                                       iconFolder: .lockOpen,
                                       folder: "Public Folder",
                                       backgroundColor: Color.colorSharedSecondary,
                                       iconColor: Color.colorSharedPrimary,
                                       isPrivate: false)
                        .onTapGesture {
                            if !sharedVM.items.isEmpty {
                                self.coordinator.show(.shared(vm: sharedVM))
                            }
                        }
                    }
                    
                }
                
            }
            .overlay(alignment: .bottomTrailing, content: {
                ButtonUploader(vm: uploaderVM)
            })
            .padding()
            .setAppNavigationBarItems(leftItem: leftItem, rightItems: [profile])
        }
        .progressBarView(isPresented: $uploaderVM.isLoading)
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


//                        ForEach(uploaderVM.itemsPhoto){ item in
//                            Row(item: item)
//                                .onTapGesture {
//
//                                    Task {
//                                        try await uploaderVM.getPhoto(item: item)
//                                    }
//                                    Task {
//                                        var updatedItem = item
//                                        updatedItem.addSharedUser(email: "matteogentili20@gmail.com")
//                                        do {
//                                            try await uploaderVM.updateItem(item: item, updatedItem: updatedItem)
//                                        } catch {
//                                            print("Errore durante l'aggiornamento dell'elemento: \(error)")
//                                        }
//                                    }




//                    SirioText(text: "Shared Files", typography: .label_md_700)
//                    if uploaderVM.itemsPhotoShared.isEmpty {
//                        SirioText(text: "Nessun Shared File", typography: .label_md_600)
//                    } else {
//                        ForEach(uploaderVM.itemsPhotoShared){ item in
//                            Row(item: item)
//                                .onTapGesture {
//                                    Task {
//                                        try? await uploaderVM.getPhoto(item: item)
//                                    }
//                                    //uploaderVM.update(item: item)
//                                }
//                        }
//                    }


//                    if !uploaderVM.retrievedPhotos.isEmpty {
//                        ScrollView(.horizontal) {
//                            HStack {
//                                ForEach(uploaderVM.retrievedPhotos, id: \.self){ image in
//                                    Image(uiImage: image)
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                        .frame(width: 100, height: 100)
//                                }
//                                .id(UUID())
//                            }
//                        }
//                    }
