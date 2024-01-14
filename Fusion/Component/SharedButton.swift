//
//  SharedButton.swift
//  Fusion
//
//  Created by Matteo Gentili on 14/01/24.
//

import SwiftUI

struct SharedButton: View {
    @ObservedObject var vm: UploaderViewModel
    @Binding var itemsToShare: [Item]
    @Binding var isSelectionModeEnabled: Bool
    @State var isPresented: Bool = false
    @State var emailToShare: String = ""
    
    init(vm: UploaderViewModel, itemsToShare: Binding<[Item]>, isSelectionModeEnabled: Binding<Bool>) {
        self.vm = vm
        self._itemsToShare = itemsToShare
        self._isSelectionModeEnabled = isSelectionModeEnabled
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                isPresented = true
                
            }, label: {
                Image(systemName: "square.and.arrow.up.circle.fill") // You can use any system icon
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.colorSharedPrimary)
                    .background(Color.white)
                    .clipShape(Circle())
            })
        }
        .alert("Share items", isPresented: $isPresented) {
            TextField("Email", text: $emailToShare)
            Button("Share", action: {
                share()
            })
        } message: {
            Text("Please enter the email of the user you want to share with")
        }
    }
    
    private func resetMode() {
        self.itemsToShare = []
        self.isSelectionModeEnabled = false
    }
    
    private func share() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                itemsToShare.forEach { item in
                    group.addTask {
                        var updatedItem = item
                        await updatedItem.shared?.append(emailToShare.lowercased())
                        try? await vm.updateItem(item: item, updatedItem: updatedItem)
                    }
                }
                
                // Attendere che tutti i task nel gruppo siano completati
                await group.waitForAll()
                
                // Ora puoi eseguire un'azione dopo che tutte le chiamate sono state completate
                DispatchQueue.main.async {
                    // Esegui l'azione qui
                    if !itemsToShare.isEmpty {
                        guard let type = itemsToShare[0].type else {
                            resetMode()
                            return
                        }
                        
                        Task {
                            switch type {
                            case .document:
                                try? await vm.fetchDocumentsCollection()
                            case .photo:
                                try? await vm.fetchPhotosCollection()
                            case .video:
                                try? await vm.fetchVideosCollection()
                            }
                        }
                    }
                    self.resetMode()
                    print("Updated eseguito")
                }
            }
        }
    }
}

#Preview {
    SharedButton(vm: UploaderViewModel(), itemsToShare: .constant([]), isSelectionModeEnabled: .constant(false))
}



