//
//  MainScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 18/12/23.
//

import SwiftUI
import SirioKitIOS

struct MainScreen: View {

    @EnvironmentObject var coordinator: Coordinator<Router>

    var body: some View {
        //if !coordinator.loginEnv.isLogged {
        if false {
            LoginScreen()
        } else {
            HomeScreen()
        }
        
    }
}

#Preview {
    MainScreen()
}
