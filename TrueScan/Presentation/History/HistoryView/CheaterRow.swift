//
//  CheaterRow.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//



import SwiftUI
import UIKit


private let historyFileThumbAssetName = "historyFileThumb"

struct CheaterRow: View {
    let rec: CheaterRecord

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
                leadingIcon

                VStack(alignment: .leading, spacing: 4.scale) {
                    Text(riskTitle(for: rec.riskScore))
                        .font(Tokens.Font.caption)
                        .foregroundStyle(Tokens.Color.textPrimary)
                }

                Spacer()

                Text("\(rec.riskScore)%")
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
            }
            .padding(.leading, 4.scale)
            .padding(.trailing, Tokens.Spacing.x12)
        }
        .frame(height: 56.scale)
        .background(Color.clear)
    }

    private var leadingIcon: some View {
        Group {
            if let data = rec.imageJPEG, let ui = UIImage(data: data) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12.scale, style: .continuous)
                        .fill(Color.black.opacity(0.08))
                        .frame(width: 48.scale, height: 48.scale)

                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48.scale, height: 48.scale)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18.scale, style: .continuous)
                        )
                }
            }
            else if rec.kind == .file {
                ZStack {
                    Color(hex: "#F2F3F5")
                    Image(historyFileThumbAssetName)
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 20.scale, height: 20.scale)
                }
                .frame(width: 48.scale, height: 48.scale)
                .clipShape(RoundedRectangle(cornerRadius: 18.scale, style: .continuous))
            } else {
                ZStack {
                    Color(hex: "#F2F3F5")
                    Image(systemName: iconName(for: rec.kind))
                        .font(Tokens.Font.caption)
                        .foregroundStyle(Tokens.Color.accent)
                }
                .frame(width: 48.scale, height: 48.scale)
                .clipShape(RoundedRectangle(cornerRadius: 18.scale, style: .continuous))
            }
        }
    }

    private func iconName(for kind: CheaterRecord.Kind) -> String {
        switch kind {
        case .image: return "photo"
        case .file:  return "folder"
        case .text:  return "text.justify.left"
        }
    }

    private func riskTitle(for score: Int) -> String {
        switch score {
        case ..<34:   return "Low risk level"
        case 34...66: return "Medium risk level"
        default:      return "High risk level"
        }
    }
}
