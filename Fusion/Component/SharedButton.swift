//
//  SharedButton.swift
//  Fusion
//
//  Created by Matteo Gentili on 14/01/24.
//

import SwiftUI
import SirioKitIOS

struct SharedButton: View {
    @ObservedObject var vm: HomeViewModel
    @Binding var itemsToShare: [Item]
    @Binding var isSelectionModeEnabled: Bool
    @Binding var mode: ActionMode
    @State var isPresented: Bool = false
    @State var emailToShare: String = ""
    @State var isPresentedError: Bool = false
    
    init(vm: HomeViewModel, itemsToShare: Binding<[Item]>, isSelectionModeEnabled: Binding<Bool>, mode: Binding<ActionMode>) {
        self.vm = vm
        self._itemsToShare = itemsToShare
        self._isSelectionModeEnabled = isSelectionModeEnabled
        self._mode = mode
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                if itemsToShare.isEmpty {
                    self.isPresentedError = true
                } else {
                    self.isPresented = true
                }
            }, label: {
                SirioIcon(data: .init(icon: .shareAlt))
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            })
            .frame(width: 50, height: 50)
            .background(Color.colorSharedPrimary)
            .clipShape(Circle())
        }
        .alert("Share items", isPresented: $isPresented) {
            TextField("Email", text: $emailToShare)
            Button("Cancel", action: {
                
            })
            Button("Share", action: {
                share()
            })
        } message: {
            Text("Please enter the email of the user you want to share with")
        }
        .alert(isPresented: $isPresentedError) {
            Alert(
                title: Text("Warning"),
                message: Text("Select at least one item"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func resetMode() {
        self.emailToShare = ""
        self.itemsToShare = []
        self.isSelectionModeEnabled = false
        self.mode = .upload
    }
    
    private func share() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                itemsToShare.forEach { item in
                    group.addTask {
                        var updatedItem = item
                        if let isPresentUser = await updatedItem.shared?.contains(emailToShare.lowercased()), !isPresentUser {
                            await updatedItem.shared?.append(emailToShare.lowercased())
                            try? await vm.updateItem(item: item, updatedItem: updatedItem)
                        } else {
                            await resetMode()
                            return
                        }
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
                            case .shared:
                                break
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
    SharedButton(vm: HomeViewModel(), itemsToShare: .constant([]), isSelectionModeEnabled: .constant(false), mode: .constant(.share))
}



