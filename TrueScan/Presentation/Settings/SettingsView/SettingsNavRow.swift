//
//  SettingsNavRow.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct SettingsNavRow: View {
    let asset: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Tokens.Spacing.x12) {
                Image(asset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Tokens.Color.accent)
                    .frame(width: 20.scale, height: 20.scale)

                Text(title)
                    .font(Tokens.Font.optionsMedium16)
                    .foregroundStyle(Tokens.Color.textPrimary)

                Spacer(minLength: 0)

                Image("chevronRight")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Tokens.Color.textSecondary.opacity(0.8))
                    .frame(width: 20.scale, height: 20.scale)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, Tokens.Spacing.x12)
            .padding(.vertical, Tokens.Spacing.x12)
            .contentShape(Rectangle())
            .accessibilityAddTraits(.isButton)
        }
        .buttonStyle(OpacityTapButtonStyle())
    }
}
