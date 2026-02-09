//
//  SearchTile.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//

import SwiftUI
import UIKit

struct SearchTile: View {
    let rec: HistoryRecord

    // MARK: - Layout constants (по ТЗ)

    private let imageCorner: CGFloat = 8        // ⬅️ радиус картинки
    private let cardCorner: CGFloat = 16        // ⬅️ радиус белой подложки
    private let innerPadding: CGFloat = 8       // ⬅️ отступ от картинки до подложки
    private let badgePadding: CGFloat = 10
    private let textTopSpacing: CGFloat = Tokens.Spacing.x8.scale

    var body: some View {
        Group {
            if rec.kind == .face, let data = rec.imageJPEG, let ui = UIImage(data: data) {
                faceCard(ui: ui)
            } else {
                nonFaceCard
            }
        }
    }

    // MARK: - Face card (white container + hard shadow)

    private func faceCard(ui: UIImage) -> some View {
        ZStack {
            // Белая подложка с жёсткой тенью
            RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
                .fill(Color.white)
                .compositingGroup()
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 4,
                    y: 4
                )

            VStack(alignment: .leading, spacing: textTopSpacing) {

                // Квадратное превью
                GeometryReader { geo in
                    let side = geo.size.width

                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                            .frame(width: side, height: side)
                            .clipped()
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: imageCorner,
                                    style: .continuous
                                )
                            )

                        // Бейдж сайта
                        if let url = SiteBadgeURLResolver.resolve(
                            iconURLString: rec.sourceIconURL,
                            linkURLString: rec.sourceLinkURL,
                            previewText: rec.sourcePreview
                        ) {
                            SiteBadgeIcon(url: url)
                                .padding(badgePadding)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .padding(.top, innerPadding)
                .padding(.horizontal, innerPadding)

                // Подпись
                Text(faceTitle)
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, innerPadding)
                    .padding(.bottom, innerPadding)
            }
        }
        .contentShape(
            RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
        )
    }

    // MARK: - Non-face card (без изменений)

    private var nonFaceCard: some View {
        VStack(spacing: Tokens.Spacing.x8.scale) {
            Image(systemName: "text.magnifyingglass")
                .font(Tokens.Font.h2)
                .foregroundStyle(Tokens.Color.accent)
                .frame(height: 120.scale)

            Text(rec.query?.isEmpty == false ? (rec.query ?? "Name search") : "Name search")
                .font(Tokens.Font.captionRegular)
                .foregroundStyle(Tokens.Color.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .padding(Tokens.Spacing.x12.scale)
        .background(
            Tokens.Color.surfaceCard,
            in: RoundedRectangle(
                cornerRadius: Tokens.Radius.medium.scale,
                style: .continuous
            )
        )
        .apply(Tokens.Shadow.card)
    }

    private var faceTitle: String {
        let t = (rec.titlePreview ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? "Face search" : t
    }
}
