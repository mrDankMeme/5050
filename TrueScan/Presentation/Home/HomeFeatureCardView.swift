//
//  HomeFeatureCardView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct HomeFeatureCardView: View {
    let iconName: String
    let title: String
    let subtitle: String
    let buttonTitle: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24.scale, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .shadow(
                    color: Tokens.Color.accent,
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )

            VStack(spacing: 0) {
                Spacer().frame(height: 24.scale)

                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48.scale, height: 48.scale)

                Spacer().frame(height: 16.scale)

                Text(title)
                    .font(Tokens.Font.medium18)
                    .tracking(-0.18)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16.scale)

                Spacer().frame(height: 8.scale)

                Text(subtitle)
                    .font(Tokens.Font.regular16)
                    .foregroundStyle(Tokens.Color.textSecondary)
                    .multilineTextAlignment(.center)
                    .tracking(-0.16)
                    .lineSpacing((1 * 16.scale) - 16.scale)
                    .padding(.horizontal, 16.scale)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer().frame(height: 24.scale)

                HStack(spacing: 8.scale) {
                    Text(buttonTitle)
                        .font(Tokens.Font.semibold16)
                        .tracking(-0.16)

                    Spacer()

                    Image("nextArrow")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20.scale, height: 20.scale)
                        .padding(.trailing, 3.scale)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20.scale)
                .frame(height: 51.scale)
                .background(
                    RoundedRectangle(cornerRadius: Tokens.Radius.medium, style: .continuous)
                        .fill(Tokens.Color.accent)
                        .shadow(
                            color: Color(hex: "#0E0E0E"),
                            radius: 0,
                            x: 2.scale,
                            y: 2.scale
                        )
                )
                .padding(.horizontal, 8.scale)
                .padding(.bottom, 8.scale)
            }
        }
        .frame(width: 343.scale, height: 241.scale)
    }
}
