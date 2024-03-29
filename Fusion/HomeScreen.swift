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
    @EnvironmentObject var coordinator: Coordinator<Router>

    @StateObject private var uploaderVM: UploaderViewModel = UploaderViewModel()
    @State private var shouldPresentActionSheet: Bool = false // Present action sheet
    @State private var shouldPresentImagePicker: Bool = false // Present Image Picker from Photo Library
    @State private var shouldPresentFilePicker: Bool = false // Present File Picker from File
    @State var privacyAuthorization: String = ""
    @State var error: String = ""
    @State private var selectedImage: UIImage?
    @State private var base64: String? // Viene riempita sia da picker image che da picker file
    @State private var pdfData: Data?
    
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
                         items: "\(uploaderVM.itemsPhoto.count) items",
                         iconFolder: .lock,
                         folder: "Private Folder",
                         backgroundColor: Color.colorPhotosSecondary,
                         iconColor: Color.colorPhotosPrimary)
                
                CardView(icon: .playCircle,
                         title: "Videos",
                         items: "\(uploaderVM.itemsVideo.count) items",
                         iconFolder: .lockOpen,
                         folder: "Private Folder",
                         backgroundColor: Color.colorVideosSecondary,
                         iconColor: Color.colorVideosPrimary)
                
                CardView(icon: .folder,
                         title: "Documents",
                         items: "\(uploaderVM.itemsDocument.count) items",
                         iconFolder: .lockOpen,
                         folder: "Public Folder",
                         backgroundColor: Color.colorDocumentsSecondary,
                         iconColor: Color.colorDocumentsPrimary)
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
                            
                    ForEach(uploaderVM.itemsPhoto){ item in
                        HStack{
                            SirioText(text: "\(item.id).jpg", typography: .label_md_600)
                            Spacer()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.8))
                        .clipShape(Rectangle())
                        .onTapGesture {
                            uploaderVM.downloadItem(item: item)
                        }
                    }
                    if !uploaderVM.retrievedPhotos.isEmpty {
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(uploaderVM.retrievedPhotos, id: \.self){ image in
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
        .progressBarView(isPresented: $uploaderVM.isLoading)
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
        .fileImporter(isPresented: $shouldPresentFilePicker, allowedContentTypes: [.pdf, .image], allowsMultipleSelection: false) { result in
            filePicker(result: result)
        }
        .onAppear {
            let email = "matteogentili20@gmail.com"
            uploaderVM.getUserIdFromEmail(email: email, completion: { value in
                print("\(email) -> id: \(value)")
            })
            
            
            let email2 = "test@gmail.com"
            uploaderVM.getUserIdFromEmail(email: email2, completion: { value in
                print("\(email2) -> id: \(value)")
            })
        }
    }
    
    
    private func filePicker(result: Result<[Foundation.URL], any Error>) {
        switch result {
        case .success(let url):
            
            guard let firstUrl = url.first else {
                print("Url non disponibile")
                return
            }
            
            if firstUrl.startAccessingSecurityScopedResource() {
                do {
                    let ext = firstUrl.getExtension()
                    let data = try Data(contentsOf: firstUrl)
                    // PDF
                    if ext == "pdf" {
                        if data.count > maxAllowedSize_Byte { // Se la dimensione del data supera quella consentita mostro errore
                            self.error = Localizable.anErrorHasOccurred
                        } else {
                            self.base64 = data.base64EncodedString() // Trasformo in base 64
                            self.pdfData = data // Riempio la variabile pdfData
                            uploaderVM.uploadDocument(data: data, ext: ext)
                        }
                    } else { // IMAGE
                        guard let image = UIImage(data: data) else {
                            self.error = Localizable.anErrorHasOccurred
                            return
                        }
                        self.selectedImage = image
                        uploaderVM.uploadImage(image: image)

                    }
                    firstUrl.stopAccessingSecurityScopedResource()
                } catch {
                    self.error = Localizable.anErrorHasOccurred
                    print("Errore durante la lettura del file o la conversione dei dati in Base64: \(error)")
                }
            } else {
                self.error = Localizable.anErrorHasOccurred
                print("Impossibile accedere in modo sicuro al file")
            }
        case .failure(let error):
            self.error = Localizable.anErrorHasOccurred
            print(error)
        }
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
