//
//  SettingsHeaderView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct SettingsHeaderView: View {
    var body: some View {
        Text("Settings")
            .font(Tokens.Font.h2)
            .foregroundStyle(Tokens.Color.textPrimary)
            .padding(.top, 8.scale)
            .padding(.horizontal, Tokens.Spacing.x16)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
