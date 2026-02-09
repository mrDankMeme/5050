//
//  OnboardingReviewsMarqueeRow.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct OnboardingReviewsMarqueeRow: View {
    enum Direction {
        case leftToRight
        case rightToLeft
    }

    let imageNames: [String]
    let direction: Direction

    private let cardSize = CGSize(width: 410.scale, height: 140.scale)
    private let spacing: CGFloat = 16.scale
    private let duration: Double = 18

    @State private var offset: CGFloat = 0

    var body: some View {
        let totalWidth = (cardSize.width * CGFloat(imageNames.count) +
                          spacing * CGFloat(max(imageNames.count - 1, 0)))

        HStack(spacing: spacing) {
            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: spacing) {
                    ForEach(imageNames, id: \.self) { name in
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .frame(width: cardSize.width, height: cardSize.height)
                            .clipped()
                    }
                }
            }
        }
        .offset(x: offset)
        .onAppear {
            startAnimation(totalWidth: totalWidth)
        }
        .onChange(of: imageNames) { _, _ in
            offset = 0
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .clipped()
    }

    private func startAnimation(totalWidth: CGFloat) {
        let directionSign: CGFloat = (direction == .leftToRight) ? 1 : -1
        let target = directionSign * (-totalWidth / 2)

        offset = 0
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            offset = target
        }
    }
}
