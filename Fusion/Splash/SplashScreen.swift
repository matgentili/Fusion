//
//  SplashScreen.swift
//  Fusion
//
//  Created by Matteo Gentili on 13/12/23.
//

import SwiftUI

struct SplashScreen: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = SplashVC()
        let navigation = UINavigationController.init(rootViewController: controller)
        return navigation as UIViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
}

#Preview {
    SplashScreen()
}
