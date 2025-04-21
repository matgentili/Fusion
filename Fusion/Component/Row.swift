//
//  Row.swift
//  Fusion
//
//  Created by Matteo Gentili on 22/12/23.
//

import SwiftUI
import SirioKitIOS

struct Row: View {
    var item: Item
    @Binding var isSelectionModeEnabled: Bool
    @State var isSelected: Bool = false
    var onSelectChange: (Bool) -> Void
    var onTapGesture: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            iconView.padding()
            
            VStack(alignment: .leading, spacing: 0){
                SirioText(text: "\(item.name)", typography: .helper_text_xs_400)
                SirioText(text: "Peso: \(item.size?.byteToMB() ?? 0.0)MB - Data: \(item.date ?? "")", typography: .helper_text_xs_400)
                //SirioText(text: "Email: \(item.emailOwner ?? "")", typography: .helper_text_xs_400)
                //SirioText(text: "Shared: \(item.shared.map({ $0 }) ?? [])", typography: .helper_text_xs_400)
            }
            Spacer()
        }
        .clipShape(Rectangle())
        .onTapGesture {
            if isSelectionModeEnabled {
                onTapRow()
            } else {
                onTapGesture()
            }
        }
    }
    
    private var iconView: some View {
        return VStack {
            if let type = item.type {
                
                VStack {
                    if isSelectionModeEnabled {
                        Button(action: {
                            onTapRow()
                        }, label: {
                            Image(systemName: self.isSelected ? "checkmark.square" : "square")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(type.getPrimaryColor())
                        })
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(type.getPrimaryColor())
                    } else {
                        SirioIcon(data: .init(icon: type.getIcon()))
                            .frame(width: 20, height: 20)
                            .foregroundStyle(type.getPrimaryColor())
                    }
                }
                .frame(width: 44, height: 44)
                .background(isSelectionModeEnabled ? Color.clear : type.getSecondaryColor())
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    private func onTapRow() {
        withAnimation {
            self.isSelected.toggle()
            self.onSelectChange(isSelected)
        }
    }
}

#Preview {
    Row(item: Item.preview, isSelectionModeEnabled: .constant(false), onSelectChange: { isSelected in }, onTapGesture: {})
}
