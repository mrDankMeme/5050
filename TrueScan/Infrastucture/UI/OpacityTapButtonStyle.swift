//
//  OpacityTapButtonStyle.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/4/25.
//


import SwiftUI

struct OpacityTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
