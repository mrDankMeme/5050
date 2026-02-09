//
//  PasscodePadView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct PasscodePadView: View {
    let onDigit: (_ digit: String) -> Void
    let onDelete: () -> Void

    private let rows: [[String]] = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"]
    ]

    var body: some View {
        VStack(spacing: 12.scale) {
            ForEach(0..<rows.count, id: \.self) { r in
                HStack(spacing: 12.scale) {
                    ForEach(rows[r], id: \.self) { d in
                        key(title: d) { onDigit(d) }
                    }
                }
            }

            HStack(spacing: 12.scale) {
                Spacer().frame(width: 72.scale, height: 52.scale)

                key(title: "0") { onDigit("0") }

                Button(action: onDelete) {
                    Image(systemName: "delete.left")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Tokens.Color.textPrimary)
                        .frame(width: 22.scale, height: 22.scale)
                        .frame(width: 72.scale, height: 52.scale)
                        .background(
                            RoundedRectangle(cornerRadius: 16.scale, style: .continuous)
                                .fill(Tokens.Color.surfaceCard)
                                .shadow(color: Tokens.Color.accent, radius: 0, x: 2.scale, y: 2.scale)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24.scale)
    }

    private func key(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Tokens.Font.bodyMedium18)
                .foregroundStyle(Tokens.Color.textPrimary)
                .frame(width: 72.scale, height: 52.scale)
                .background(
                    RoundedRectangle(cornerRadius: 16.scale, style: .continuous)
                        .fill(Tokens.Color.surfaceCard)
                        .shadow(color: Tokens.Color.accent, radius: 0, x: 2.scale, y: 2.scale)
                )
        }
        .buttonStyle(.plain)
    }
}
