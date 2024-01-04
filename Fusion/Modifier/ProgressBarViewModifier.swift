//
//  ProgressBarViewModifier.swift
//  Fusion
//
//  Created by Matteo Gentili on 03/01/24.
//

import Foundation
import SwiftUI
import SirioKitIOS

struct ProgressBarViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    public func body(content: Content) -> some View {
        content.overlay(progressView())
    }
    
    @ViewBuilder private func progressView() -> some View {
        if isPresented {
            ZStack {
                VStack {
                    Color.black.opacity(0.3)
                }
                
                ProgressView(label: {
                    SirioText(text: "Loading", typography: .label_md_400)
                        .foregroundColor(.white)
                })
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .tint(.white)
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
