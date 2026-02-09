//
//  Presentation/Cheater/Result/LegendDot.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI

struct LegendDot: View {
    let color: Color
    let title: String

    var body: some View {
        HStack(spacing: 8.scale) {
            Circle()
                .fill(color)
                .frame(width: 20.scale, height: 20.scale)

            Text(title)
                .font(Tokens.Font.bodyMedium)
                .tracking(-0.01 * 16.scale)
                .foregroundColor(Tokens.Color.textSecondary)
        }
    }
}
