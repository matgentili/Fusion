//
//  FusionApp.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI

@main
struct FusionApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
