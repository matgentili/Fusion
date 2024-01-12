//
//  Coordinator.swift
//  Manager
//
//  Created by Matteo Gentili on 09/10/23.
//

import SwiftUI

enum Router: NavigationRouter {
    
    case main // Main
    case home  // Home
    case signIn // SignIn
    case signUp // SignUp
    case detail(vm: UploaderViewModel, type: ItemType) // Detail
    
    public var transition: NavigationTransitionStyle {
        return .push
    }
    
    @ViewBuilder
    public func view() -> some View {
        switch self {
        case .main:
            MainScreen()
        case .home:
            HomeScreen()
        case .signIn:
            SignInScreen()
        case .signUp:
            SignUpScreen()
        case .detail(let vm, let type):
            DetailScreen(vm: vm, type: type)
        }
    }
}
