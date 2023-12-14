//
//  Coordinator.swift
//  Manager
//
//  Created by Matteo Gentili on 09/10/23.
//

import SwiftUI

public protocol NavigationRouter {
    
    associatedtype V: View

    var transition: NavigationTransitionStyle { get }
    
    /// Creates and returns a view of assosiated type
    ///
    @ViewBuilder
    func view() -> V
}
