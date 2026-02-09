//
//  ImageAnalysisHeader.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import SwiftUI

struct ImageAnalysisHeader: View {
    let back: () -> Void

    var body: some View {
        HStack {
            BackButton(size: 44.scale, action: back)
            Spacer()
            Text("Image analysis")
                .font(Tokens.Font.bodyMedium18)
                .tracking(-0.01 * 18.scale)
                .foregroundColor(Tokens.Color.textPrimary)
            Spacer()
            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
        .padding(.horizontal, 16.scale)
        .padding(.bottom, 12.scale)
    }
}

// MARK: - Back Button
struct BackButton: View {
    let size: CGFloat
    let action: () -> Void

    private let glyphScale: CGFloat = 0.72
    private let trimPadding: CGFloat = -4

    var body: some View {
        Button(action: action) {
            ZStack {


                
                if let ui = UIImage(named: "backButton") {
                    Image(uiImage: ui)
                        .resizable()
                        .renderingMode(.original)
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(
                            width: (size * glyphScale / 1.5).scale,
                            height: (size * glyphScale / 1.5).scale
                        )
                        .padding(trimPadding.scale)
                        .accessibilityHidden(true)
                } else {
                    Image(systemName: "arrow.left")
                        .font(Tokens.Font.semibold20)

                        .foregroundColor(Tokens.Color.textPrimary)
                }
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Back"))
    }
}
