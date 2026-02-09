//
//  SiteFaviconBadge.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//




import SwiftUI

struct SiteFaviconBadge: View {

    let faviconURL: URL?

    // Размер “пейджа” как в вашем дизайне (можно подогнать позже)
    private let badgeSize: CGFloat = 28
    private let iconSize: CGFloat = 16

    var body: some View {
        ZStack {
            // Белый пейдж
            RoundedRectangle(cornerRadius: 10.scale, style: .continuous)
                .fill(Color.white)
                .shadow(
                    color: Color.black.opacity(0.08),
                    radius: 6.scale,
                    x: 0,
                    y: 2.scale
                )

            // Иконка сайта (или fallback)
            Group {
                if let faviconURL {
                    AsyncImage(url: faviconURL) { phase in
                        switch phase {
                        case .empty:
                            fallbackIcon
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        case .failure:
                            fallbackIcon
                        @unknown default:
                            fallbackIcon
                        }
                    }
                } else {
                    fallbackIcon
                }
            }
            .frame(width: iconSize.scale, height: iconSize.scale)
        }
        .frame(width: badgeSize.scale, height: badgeSize.scale)
    }

    private var fallbackIcon: some View {
        // fallback, если favicon нет/не загрузился
        Image(systemName: "globe")
            .font(.system(size: 12.scale, weight: .semibold))
            .foregroundStyle(Tokens.Color.textPrimary)
    }
}
