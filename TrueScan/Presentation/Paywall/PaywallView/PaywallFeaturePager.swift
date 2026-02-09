//
//  PaywallFeaturePager.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct PaywallFeaturePager: View {
    let items: [FeatureItem]
    @Binding var selectedIndex: Int

    private let interval: TimeInterval = 2.0
    @State private var isUserDragging = false

    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                PaywallFeatureCard(item: item)
                    .padding(.horizontal, Tokens.Spacing.x16)
                    .padding(.vertical, Tokens.Spacing.x16)
                    .tag(idx)
                    .shadow(
                        color: Tokens.Color.accent,
                        radius: 0,
                        x: 2.scale,
                        y: 2.scale
                    )
            }
        }
        .frame(height: 121.scale)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .highPriorityGesture(
            DragGesture(minimumDistance: 1)
                .onChanged { _ in
                    if !isUserDragging { isUserDragging = true }
                }
                .onEnded { _ in
                    isUserDragging = false
                }
        )
        .task {
            guard !items.isEmpty else { return }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                if isUserDragging { continue }
                withAnimation(.easeInOut(duration: 0.35)) {
                    selectedIndex = (selectedIndex + 1) % items.count
                }
            }
        }
    }
}

struct PaywallFeatureCard: View {
    let item: FeatureItem

    var body: some View {
        RoundedRectangle(cornerRadius: 22.scale, style: .continuous)
            .fill(Tokens.Color.surfaceCard)
            .overlay(
                HStack(alignment: .top, spacing: Tokens.Spacing.x12) {
                    Image(item.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22.scale, height: 22.scale)
                        .padding(.leading, 2.scale)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(Tokens.Font.bodyMedium)
                            .foregroundStyle(Tokens.Color.textPrimary)

                        Text(item.subtitle)
                            .font(Tokens.Font.caption)
                            .foregroundStyle(Tokens.Color.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                }
                .padding(.vertical, Tokens.Spacing.x12)
                .padding(.horizontal, Tokens.Spacing.x16)
            )
            .shadow(color: .black.opacity(0.08), radius: 10.scale, y: 4.scale)
    }
}
