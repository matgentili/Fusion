//
//  FusionApp.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI
import SirioKitIOS

@main
struct FusionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init(){
        // Register fonts from library
        Fonts.registerFonts()
    }
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .edgesIgnoringSafeArea(.all)
        }
    }
}
