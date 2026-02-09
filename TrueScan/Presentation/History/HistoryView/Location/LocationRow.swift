//
//  LocationRow.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//


import SwiftUI
import UIKit

struct LocationRow: View {
    let item: LocationHistoryItem

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.scale, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .compositingGroup()
                .shadow(
                    color: Color(hex: "#0E0E0E"),
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )

            HStack(spacing: Tokens.Spacing.x12) {
                thumb

                Text(item.title)
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(.leading, 4.scale)
            .padding(.trailing, Tokens.Spacing.x12)
        }
        .frame(height: 56.scale)
        .background(Color.clear)
    }

    private var thumb: some View {
        Group {
            if let data = item.thumbnailJPEG, let ui = UIImage(data: data) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12.scale, style: .continuous)
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 48.scale, height: 48.scale)

                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48.scale, height: 48.scale)
                        .clipped()
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18.scale, style: .continuous)
                        )
                }
            }
                else {
                ZStack {
                    Color(hex: "#F2F3F5")
                    Image(systemName: "mappin.and.ellipse")
                        .font(Tokens.Font.caption)
                        .foregroundStyle(Tokens.Color.accent)
                }
                .frame(width: 48.scale, height: 48.scale)
                .clipShape(RoundedRectangle(cornerRadius: 18.scale, style: .continuous))
            }
        }
    }
}
