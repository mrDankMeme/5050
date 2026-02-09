//
//  OnboardingStepProgress.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//



import SwiftUI

struct OnboardingStepProgress: View {
    let current: Int
    let total: Int

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 4.scale
            let available = geo.size.width - spacing * CGFloat(total - 1)
            let segmentWidth = max(0, available / CGFloat(total))

            HStack(spacing: spacing) {
                ForEach(1...total, id: \.self) { step in
                    RoundedRectangle(cornerRadius: 2.scale, style: .continuous)
                        .fill(step == current ? Tokens.Color.accent : Tokens.Color.borderNeutral.opacity(0.25))
                        .frame(width: segmentWidth, height: 4.scale)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .animation(nil, value: current)
        }
        .frame(height: 4.scale)
    }
}
