//
//  ZStackForFileName.swift
//  CheaterBuster
//

import SwiftUI

struct ZStackForFileName: View {
    let name: String

    var body: some View {
        VStack(spacing: 8.scale) {
            ZStack {
                RoundedRectangle(cornerRadius: 22.scale, style: .continuous)
                    .fill(Color.white)
                    .shadow(
                        color: Tokens.Color.accent,
                        radius: 0,
                        x: 2.scale,
                        y: 2.scale
                    )
                Image("ic_file_analysis_placeholder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64.scale, height: 64.scale)
            }
            .frame(width: 112.scale, height: 112.scale)

            Text(name)
                .font(Tokens.Font.bodyMedium18) 
                .foregroundStyle(Tokens.Color.textPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 16.scale)
        }
    }
}
