//
//  RedFlagCard.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/02/25.
//

import SwiftUI

struct RedFlagCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.scale, style: .continuous)
                .fill(Color(hex: "#FFF3F3"))
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 2,
                    y: 2
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16.scale, style: .continuous)
                        .stroke(Color(hex: "#FFB9B9"), lineWidth: 1.scale)
                )

            HStack(alignment: .top, spacing: 12.scale) {
                Image("danger")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 20.scale, height: 20.scale)
                    .padding(.top, 2.scale)

                VStack(alignment: .leading, spacing: 8.scale) {
                    Text(title)
                        .font(Tokens.Font.bodyMedium)
                        .foregroundStyle(Tokens.Color.textPrimary)

                    Text(subtitle)
                        .font(Tokens.Font.captionRegular)
                        .foregroundStyle(Tokens.Color.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 14.scale)
            .padding(.horizontal, 16.scale)
        }
        .frame(maxWidth: .infinity)
    }
}
