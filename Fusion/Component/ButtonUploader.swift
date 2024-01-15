//
//  ButtonUploader.swift
//  Fusion
//
//  Created by Matteo Gentili on 12/01/24.
//

import SwiftUI
import Photos
import SirioKitIOS

struct ButtonUploader: View {
    @State private var shouldPresentActionSheet: Bool = false // Present action sheet
    @State private var shouldPresentImagePicker: Bool = false // Present Image Picker from Photo Library
    @State private var shouldPresentFilePicker: Bool = false // Present File Picker from File
    @State var privacyAuthorization: String = ""
    @State var error: String = ""
    
    @State private var selectedImage: UIImage?
    @State private var base64: String? // Viene riempita sia da picker image che da picker file
    @State private var data: Data?
    
    @ObservedObject var vm: HomeViewModel
    
    private var maxAllowedSize_MB: Int = 100
    
    private var maxAllowedSize_Byte: Int {
        maxAllowedSize_MB * 1024 * 1024
    }
    
    init(vm: HomeViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                shouldPresentActionSheet.toggle()
            }, label: {
                SirioIcon(data: .init(icon: .plus))
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            })
            .frame(width: 50, height: 50)
            .background(Color.green)
            .clipShape(Circle())
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
                        self.privacyAuthorization = "L'app non ha accesso alle tue foto. Per abilitare l'accesso, tocca Impostazioni e concedi l'accesso."
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
                Task {
                    do {
                        try await vm.uploadImage(image: selectedImage)
                    } catch {
                        self.error = Localizable.anErrorHasOccurred
                    }
                }
            }, error: $error, shouldPresentPreview: .constant(false))
        }
        .fileImporter(isPresented: $shouldPresentFilePicker, allowedContentTypes: [.pdf, .image, .movie], allowsMultipleSelection: false) { result in
            filePicker(result: result)
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
                    let ext = firstUrl.getExtension().lowercased()
                    let data = try Data(contentsOf: firstUrl)
                    // PDF
                    if ext == "pdf" || ext == "mp4" || ext == "mov" {
                        if data.count > maxAllowedSize_Byte { // Se la dimensione del data supera quella consentita mostro errore
                            self.error = Localizable.anErrorHasOccurred
                        } else {
                            self.base64 = data.base64EncodedString() // Trasformo in base 64
                            self.data = data // Riempio la variabile pdfData
                            Task {
                                do {
                                    if ext == "pdf" {
                                        try await vm.uploadDocument(data: data)
                                    } else if ext == "mp4" ||  ext == "mov" {
                                        try await vm.uploadVideo(data: data)
                                    } else {
                                        self.error = Localizable.anErrorHasOccurred
                                    }
                                } catch {
                                    self.error = Localizable.anErrorHasOccurred
                                }
                            }
                        }
                    } else { // IMAGE
                        guard let image = UIImage(data: data) else {
                            self.error = Localizable.anErrorHasOccurred
                            return
                        }
                        self.selectedImage = image
                        Task {
                            do {
                                try await vm.uploadImage(image: selectedImage)
                            } catch {
                                self.error = Localizable.anErrorHasOccurred
                            }
                        }
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
    ButtonUploader(vm: HomeViewModel())
}
