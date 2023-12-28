//
//  PhotoLibraryPickerView.swift
//  Fusion
//
//  Created by Matteo Gentili on 28/12/23.
//

import Foundation
import SwiftUI
import PhotosUI
import Photos

struct PhotoLibraryPickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var maxAllowedSize_Byte: Int
    var onImageSelected: (() -> Void)?
    @Binding var error: String
    @Binding var shouldPresentPreview: Bool

    @Environment(\.presentationMode) private var presentationMode
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoLibraryPickerView
        
        init(parent: PhotoLibraryPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let selectedItem = results.first else {
                parent.presentationMode.wrappedValue.dismiss()
                return
            }
            
            let itemProvider = selectedItem.itemProvider
            
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, _ in // data, error in
                    if let image = image as? UIImage {
                        self.customPicker(data: image.pngData())
                        self.parent.onImageSelected?()
                    } else {
                        self.parent.error = Localizable.anErrorHasOccurred
                    }
                }
            } else {
                // Se non può caricare direttamente un'immagine, verifica il tipo di file
                if let typeIdentifier = itemProvider.registeredTypeIdentifiers.first {
                    print("Type Identifier:", typeIdentifier)
                    
                    if UTType(typeIdentifier)!.conforms(to: .image) {
                        // Gestisci l'immagine in base al tipo di file
                        itemProvider.loadDataRepresentation(forTypeIdentifier: typeIdentifier) { data, _ in // data, error in
                            self.customPicker(data: data)
                            self.parent.onImageSelected?()
                        }
                    } else {
                        print("Tipo di file non supportato.")
                        self.parent.error = Localizable.anErrorHasOccurred
                        self.parent.presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    print("Nessun tipo di file registrato.")
                    self.parent.error = Localizable.anErrorHasOccurred
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
        
        func customPicker(data: Data?){
            if let data = data, let image = UIImage(data: data) {
                self.parent.selectedImage = image
                self.parent.presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    self.parent.shouldPresentPreview = true
                })
            } else {
                self.parent.error = Localizable.anErrorHasOccurred
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
}
