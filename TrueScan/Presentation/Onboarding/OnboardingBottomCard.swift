//
//  OnboardingBottomCard.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

struct OnboardingBottomCard<Content: View>: View {
    let height: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(.top, 32.scale)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 32.scale,
                bottomLeadingRadius: 0.scale,
                bottomTrailingRadius: 0.scale,
                topTrailingRadius: 32.scale,
                style: .continuous
            )
            .fill(Tokens.Color.surfaceCard)
            .shadow(color: Color.black.opacity(0.07), radius: 10.scale, y: (-2).scale)
        )
        .ignoresSafeArea(.container, edges: .bottom)
        .accessibilityIdentifier("onboarding.bottomCard")
    }
}
