//
//  View+Extension.swift
//  Fusion
//
//  Created by Matteo Gentili on 18/12/23.
//

import SwiftUI

extension View {
    func roundedCorner(_ radius: Double, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

extension View {
    
    /// progressBarView
    /// - Parameter isPresented: binding presenting loading
    func progressBarView(isPresented: Binding<Bool>) -> some View {
        return modifier(ProgressBarViewModifier(isPresented: isPresented))
    }
}
