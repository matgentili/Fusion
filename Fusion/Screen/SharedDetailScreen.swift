//
//  SharedDetailScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 12/01/24.
//

import SwiftUI

struct SharedDetailScreen: View {
    @ObservedObject var vm: SharedItemsViewModel
 
    init(vm: SharedItemsViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    SharedDetailScreen(vm: SharedItemsViewModel())
}
