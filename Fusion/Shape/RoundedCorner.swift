//
//  RoundedCorner.swift
//  Fusion
//
//  Created by Matteo Gentili on 18/12/23.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: Double = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
