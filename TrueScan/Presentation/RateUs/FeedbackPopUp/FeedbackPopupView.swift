// Presentation/Feedback/FeedbackPopupView.swift
// TrueScan / CheaterBuster
//
// Exact design version (custom icons from Assets)

import SwiftUI
import UIKit

struct FeedbackPopupView: View {

    struct Model: Equatable {
        let title: String
        let subtitle: String

        /// Asset names (you will add these images to Assets)
        let negativeIconAssetName: String
        let positiveIconAssetName: String

        let negativeAccessibilityLabel: String
        let positiveAccessibilityLabel: String

        init(
            title: String,
            subtitle: String,
            negativeIconAssetName: String = "feedback_thumb_down",
            positiveIconAssetName: String = "feedback_thumb_up",
            negativeAccessibilityLabel: String = "Not helpful",
            positiveAccessibilityLabel: String = "Helpful"
        ) {
            self.title = title
            self.subtitle = subtitle
            self.negativeIconAssetName = negativeIconAssetName
            self.positiveIconAssetName = positiveIconAssetName
            self.negativeAccessibilityLabel = negativeAccessibilityLabel
            self.positiveAccessibilityLabel = positiveAccessibilityLabel
        }
    }

    let model: Model
    let onDismiss: () -> Void
    let onNegative: () -> Void
    let onPositive: () -> Void

    // MARK: - Exact layout constants

    private let cardWidth: CGFloat = 343.scale
    private let cardHeight: CGFloat = 187.scale

    private let cardCornerRadius: CGFloat = 32.scale

    private let iconSize: CGFloat = 20.scale

    private let buttonWidth: CGFloat = 161.5.scale
    private let buttonHeight: CGFloat = 51.scale
    private let buttonsSpacing: CGFloat = 4.scale
    private let buttonCornerRadius: CGFloat = 24.scale

    private let subtitleTracking: CGFloat = -0.16

    // MARK: - Hard shadow constants (as requested)

    private let hardShadowOffset: CGFloat = 2.2.scale
    private let hardShadowRadius: CGFloat = 0

    var body: some View {
        ZStack {
            // ✅ Accent hard shadow ONLY for the white card background
            RoundedRectangle(cornerRadius: 16.scale, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .shadow(
                    color: Tokens.Color.accent,
                    radius: hardShadowRadius,
                    x: hardShadowOffset,
                    y: hardShadowOffset
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cardCornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )

            // Content on top (no accent shadow affecting texts/buttons)
            VStack(spacing: 14.scale) {

                VStack(spacing: 8.scale) {
                    Text(model.title)
                        .font(Tokens.Font.subtitle)
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(model.subtitle)
                        .font(Tokens.Font.regular16)
                        .tracking(subtitleTracking)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6.4.scale)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 4.scale)
                }
                .padding(.horizontal, 16.scale)
                .padding(.top, 11.scale)

                HStack(spacing: buttonsSpacing) {
                    feedbackButton(
                        iconAssetName: model.negativeIconAssetName,
                        background:  Color(hex: "#FAEBF0"),
                        accessibilityLabel: model.negativeAccessibilityLabel,
                        action: onNegative
                    )

                    feedbackButton(
                        iconAssetName: model.positiveIconAssetName,
                        background: Tokens.Color.accent,
                        accessibilityLabel: model.positiveAccessibilityLabel,
                        action: onPositive
                    )
                }
                .padding(.top, 6.scale)
            }
            .frame(width: cardWidth, height: cardHeight)
        }
        .frame(width: cardWidth, height: cardHeight)
        .accessibilityIdentifier("feedback.popup.card")
        .onTapGesture { }
    }

    private func feedbackButton(
        iconAssetName: String,
        background: Color,
        accessibilityLabel: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
            onDismiss()
        } label: {
            ZStack {
                // ✅ Hard black shadow ONLY for the button background
                RoundedRectangle(cornerRadius: 8.scale, style: .continuous)
                    .fill(background)
                    .shadow(
                        color: Color.black,
                        radius: hardShadowRadius,
                        x: hardShadowOffset,
                        y: hardShadowOffset
                    )

                Image(iconAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
            }
            .frame(width: buttonWidth, height: buttonHeight)
        }
        .buttonStyle(OpacityTapButtonStyle())
        .accessibilityLabel(accessibilityLabel)
    }
}
