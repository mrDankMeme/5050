//
//  HomeMainContentView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//



import SwiftUI

struct HomeMainContentView: View {
    @Binding var activeFlow: HomeView.ActiveFlow?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24.scale) {
                Text("PimСheater AI")
                    .font(Tokens.Font.h2)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .padding(.top, Tokens.Spacing.x24)
                    .padding(.bottom, 0.scale)

                VStack(spacing: 12.scale) {
                    Button {
                        withAnimation { activeFlow = .search }
                    } label: {
                        HomeFeatureCardView(
                            iconName: "home.search",
                            title: "Find profiles by face",
                            subtitle: "Find out if this person is really who they say they are.",
                            buttonTitle: "Search by photo"
                        )
                    }
                    .buttonStyle(OpacityTapButtonStyle())

                    Button {
                        withAnimation { activeFlow = .cheater }
                    } label: {
                        HomeFeatureCardView(
                            iconName: "home.warning",
                            title: "Detect scam in messages",
                            subtitle: "AI uncovers hidden red flags, manipulation, or risky behavior.",
                            buttonTitle: "Check messages"
                        )
                    }
                    .buttonStyle(OpacityTapButtonStyle())

                    Button {
                        withAnimation { activeFlow = .findPlace }
                    } label: {
                        HomeFeatureCardView(
                            iconName: "home.location",
                            title: "Find out the location from a photo",
                            subtitle: "AI Analysis Surroundings and Architecture to Pinpoint the Location",
                            buttonTitle: "Find a Place"
                        )
                    }
                    .buttonStyle(OpacityTapButtonStyle())
                }
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer().frame(height: 24.scale)
            }
            .padding(.horizontal, Tokens.Spacing.x16)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .offset(x: activeFlow != nil ? -40.scale : 0)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.9),
            value: activeFlow
        )
    }
}
