//
//  PaywallPlanRowView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import SwiftUI

struct PaywallPlanRowView: View {
    let title: String
    let subtitle: String?
    let trailingPrice: String?
    let selected: Bool
    let highlighted: Bool
    let badge: String?
    let fixedHeight: CGFloat?
    let isLoaded: Bool
    let action: () -> Void

    var body: some View {
        let isSelected = selected
        let isFeatured = highlighted

        let strokeColor: SwiftUI.Color = {
            if isSelected { return Tokens.Color.accent }
            if isFeatured { return Tokens.Color.borderNeutral.opacity(0.6) }
            return Tokens.Color.borderNeutral.opacity(0.35)
        }()

        let displayTitle = isLoaded ? (title.isEmpty ? "—" : title) : " "
        let displaySubtitle = isLoaded ? subtitle : nil
        let displayTrailingPrice = isLoaded ? trailingPrice : nil

        let shape = RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)

        return Button(action: action) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: Tokens.Spacing.x12) {
                    ZStack {
                        Circle()
                            .strokeBorder(
                                isSelected ? Tokens.Color.accent : Tokens.Color.textPrimary,
                                lineWidth: 1.scale
                            )
                            .frame(width: 28.scale, height: 28.scale)

                        if isSelected {
                            Circle()
                                .fill(Tokens.Color.accent)
                                .frame(width: 18.scale, height: 18.scale)
                        }
                    }

                    VStack(alignment: .leading, spacing: 4.scale) {
                        Text(displayTitle)
                            .font(Tokens.Font.bodyMedium16)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .lineLimit(1)
                            .redacted(reason: isLoaded ? [] : .placeholder)

                        if let displaySubtitle, !displaySubtitle.isEmpty {
                            Text(displaySubtitle)
                                .font(Tokens.Font.caption)
                                .foregroundStyle(Color.black.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Spacer()

                    if let displayTrailingPrice {
                        Text(displayTrailingPrice)
                            .font(Tokens.Font.bodyMedium16)
                            .foregroundStyle(Tokens.Color.textPrimary)
                            .lineLimit(1)
                            .redacted(reason: isLoaded ? [] : .placeholder)
                    }
                }
                .contentShape(Rectangle())
                .padding(.horizontal, Tokens.Spacing.x16)
                .frame(height: fixedHeight)
                .background {
                    ZStack {
                        shape
                            .fill(Tokens.Color.surfaceCard)
                            .shadow(
                                color: Color(hex: "#0E0E0E"),
                                radius: 0,
                                x: 2.scale,
                                y: 2.scale
                            )

                        shape
                            .stroke(strokeColor, lineWidth: 1.scale)
                    }
                }

                if let badge, isLoaded {
                    ZStack {
                        Capsule(style: .continuous)
                            .fill(Tokens.Color.accent)
                            .shadow(
                                color: Color(hex: "#0E0E0E"),
                                radius: 0,
                                x: 2.scale,
                                y: 2.scale
                            )

                        Text(badge)
                            .font(Tokens.Font.bodyMedium16)
                            .foregroundStyle(.white)
                    }
                    .frame(width: 90.scale, height: 21.scale)
                    .padding(.trailing, Tokens.Spacing.x12)
                    .offset(y: -12.scale)

                }
            }
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(OpacityTapButtonStyle())
        .disabled(!isLoaded)
    }
}
