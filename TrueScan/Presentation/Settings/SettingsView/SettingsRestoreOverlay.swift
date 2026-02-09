//
//  SettingsRestoreOverlay.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct SettingsRestoreOverlay: View {
    var body: some View {
        HStack(spacing: Tokens.Spacing.x8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Tokens.Color.textPrimary))
                .scaleEffect(1.15)

            Text("Restoring…")
                .font(Tokens.Font.medium16)
                .foregroundStyle(Tokens.Color.textPrimary)
        }
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.vertical, Tokens.Spacing.x12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Tokens.Radius.small, style: .continuous))
        .apply(Tokens.Shadow.card)
    }
}
