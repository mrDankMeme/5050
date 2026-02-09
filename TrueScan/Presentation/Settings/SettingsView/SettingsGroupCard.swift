//
//  SettingsGroupCard.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct SettingsGroupCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            RoundedRectangle(cornerRadius: 8.scale, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .shadow(
                    color: Color(hex:"#0160D2"),
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )
        )
        
    }
}
