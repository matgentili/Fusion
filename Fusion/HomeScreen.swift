//
//  HomeScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI
import SirioKitIOS
import Charts
import Photos

struct HomeScreen: View {
    @StateObject private var uploaderVM = UploaderViewModel()
    @State private var shouldPresentActionSheet: Bool = false // Present action sheet
    @State private var shouldPresentImagePicker: Bool = false // Present Image Picker from Photo Library
    @State private var shouldPresentFilePicker: Bool = false // Present File Picker from File
    @State var privacyAuthorization: String = ""
    @State var error: String = ""
    @State private var selectedImage: UIImage?
    
    private var maxAllowedSize_MB: Int = 10
    private var maxAllowedSize_Byte: Int {
        maxAllowedSize_MB * 1024 * 1024
    }
    private var leftItem: AppNavigationItemData {
        return AppNavigationItemData(icon: .bars, action: {
            
        })
    }
    
    private var profile: AppNavigationItemData {
        return AppNavigationItemData(icon: .user, action: {
            
        })
    }
    
    private var legendaView: some View {
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
    
    private var floatingButton: some View {
        VStack {
            Spacer() // Add space to push the button to the bottom
            HStack {
                Spacer() // Add space to push the button to the right
                Button(action: {
                    shouldPresentActionSheet.toggle()
                }, label: {
                    Image(systemName: "plus.circle.fill") // You can use any system icon
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                        .background(Color.white)
                        .clipShape(Circle())
                })
            }
        }
    }
    
    private var carouselView: some View {
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
    }
    
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
                        
                        legendaView
                    }
                    .padding(.vertical)
                    
                    carouselView
                   
                    SirioText(text: "Latest Files", typography: .label_md_700)
                                        
                    if !uploaderVM.retrievedImages.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(uploaderVM.retrievedImages, id: \.self){ image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100)
                                }
                                .id(UUID())
                            }
                        }
                    }
                }
            }
            .overlay(floatingButton, alignment: .bottomTrailing)
            .padding()
            .setAppNavigationBarItems(leftItem: leftItem, rightItems: [profile])
            
        }
        .actionSheet(isPresented: $shouldPresentActionSheet) { () -> ActionSheet in
            ActionSheet(title: Text("Scegli un documento"),
                        message: Text("Seleziona un file fino a \(maxAllowedSize_MB) MB."),
                        buttons: [ActionSheet.Button.default(Text("Libreria foto"), action: {
                // Request permission to access photo library
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    
                    if status == .authorized || status == .limited || status == .restricted {
                        self.shouldPresentImagePicker = true
                    } else {
                        self.privacyAuthorization = "L' app non ha accesso alle tue foto. Per abilitare l'accesso, tocca Impostazioni e concedi l'accesso."
                        print("Accesso alla libreria foto non concesso")
                    }
                }
                
            }), ActionSheet.Button.default(Text("File"), action: {
                self.shouldPresentFilePicker = true
            }), ActionSheet.Button.cancel(Text("Annulla"))])
        }
        // Image picker
        .sheet(isPresented: $shouldPresentImagePicker) {
            PhotoLibraryPickerView(selectedImage: self.$selectedImage,
                                   maxAllowedSize_Byte: maxAllowedSize_Byte,
                                   onImageSelected: {
                uploaderVM.uploadImage(image: selectedImage)
            }, error: $error,
                                   shouldPresentPreview: .constant(false))
        }
    }
}

#Preview {
    HomeScreen()
}
