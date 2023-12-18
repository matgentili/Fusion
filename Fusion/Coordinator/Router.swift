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
    case login  // Home
    
    
    public var transition: NavigationTransitionStyle {
        switch self {
        case .main:
            return .push
        case .home:
            return .push
        case .login:
            return .push
        }
    }
    
    @ViewBuilder
    public func view() -> some View {
        switch self {
        case .main:
            MainScreen()
        case .home:
            HomeScreen()
        case .login:
            LoginScreen()
        }
    }
}
