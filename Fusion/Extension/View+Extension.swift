//
//  View+Extension.swift
//  Fusion
//
//  Created by Matteo Gentili on 18/12/23.
//

import SwiftUI

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}
