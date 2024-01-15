//
//  DeleteButton.swift
//  Fusion
//
//  Created by Matteo Gentili on 15/01/24.
//

import SwiftUI
import SirioKitIOS

struct DeleteButton: View {
    @ObservedObject var vm: HomeViewModel
    @Binding var itemsToDelete: [Item]
    @Binding var isSelectionModeEnabled: Bool
    var type: ItemType
    @State var isPresented: Bool = false
    @State var isPresentedError: Bool = false
    
    init(vm: HomeViewModel, itemsToDelete: Binding<[Item]>, isSelectionModeEnabled: Binding<Bool>, type: ItemType) {
        self.vm = vm
        self._itemsToDelete = itemsToDelete
        self._isSelectionModeEnabled = isSelectionModeEnabled
        self.type = type
    }
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                if itemsToDelete.isEmpty {
                    self.isPresentedError = true
                } else {
                    self.isPresented = true
                }
            }, label: {
                SirioIcon(data: .init(icon: .trash))
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
            })
            .frame(width: 50, height: 50)
            .background(Color.red)
            .clipShape(Circle())
        }
        .alert(isPresented: $isPresented) {
            Alert(
                title: Text("Warning"),
                message: Text("Are you sure you want to delete the selected items?"),
                primaryButton: .default(Text("OK"), action: {
                    // Azione da eseguire quando si preme OK
                    delete()
                }),
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
        .overlay(
            VStack {
                EmptyView() // Spazio vuoto per separare gli alert
            }
            .alert(isPresented: $isPresentedError) {
                Alert(
                    title: Text("Warning"),
                    message: Text("Select at least one item"),
                    dismissButton: .default(Text("OK"))
                )
            }
        )
    }
    
    private func resetMode() {
        self.itemsToDelete = []
        self.isSelectionModeEnabled = false
    }
    
    private func delete() {
        Task {
            await withTaskGroup(of: Void.self) { group in
                if type == .shared { // Se sono negli shared non devo eliminare l'item ma soltanto eliminare la mia email da shared per non vederlo più
                    itemsToDelete.forEach { item in
                        group.addTask {
                            var updatedItem = item
                            guard let index = await updatedItem.shared?.firstIndex(of: vm.profile.email) else {
                                return
                            }
                            updatedItem.shared?.remove(at: index)
                            try? await vm.updateItem(item: item, updatedItem: updatedItem)
                        }
                    }
                } else {
                    itemsToDelete.forEach { item in
                        group.addTask {
                            try? await vm.deleteItem(item: item)
                        }
                    }
                }
                
                
                // Attendere che tutti i task nel gruppo siano completati
                await group.waitForAll()
                
                // Ora puoi eseguire un'azione dopo che tutte le chiamate sono state completate
                DispatchQueue.main.async {
                    Task {
                        switch type {
                        case .document:
                            try? await vm.fetchDocumentsCollection()
                        case .photo:
                            try? await vm.fetchPhotosCollection()
                        case .video:
                            try? await vm.fetchVideosCollection()
                        case .shared:
                            try? await vm.downloadSharedItems()
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
    DeleteButton(vm: HomeViewModel(), itemsToDelete: .constant([]), isSelectionModeEnabled: .constant(false), type: .document)
}
