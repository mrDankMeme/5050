//
//  OnboardingSlideScreen.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//



import SwiftUI

struct OnboardingSlideScreen: View {
    let slide: OnboardingSlide
    let bottomCardHeight: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                let isSmallStatusBar = DeviceLayout.type == .smallStatusBar
                let isNotch = DeviceLayout.type == .notch

                if slide.isFullScreenBackground {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: isSmallStatusBar ? 130.scale : (isNotch ? 80.scale : 80.scale))

                        Image("onb.youDeserve")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 252.scale, height: 89.scale)
                            .frame(maxWidth: .infinity)

                        Spacer(minLength: 32.scale)

                        VStack(spacing: 24.scale) {
                            OnboardingReviewsMarqueeRow(
                                imageNames: ["onb.left1", "onb.left2", "onb.left3", "onb.left4"],
                                direction: .leftToRight
                            )

                            OnboardingReviewsMarqueeRow(
                                imageNames: ["onb.right1", "onb.right2", "onb.right3", "onb.right4"],
                                direction: .rightToLeft
                            )
                        }
                        .frame(height: 140.scale * 2 + 24.scale)
                        .scaleEffect(DeviceLayout.isSmallStatusBarPhone ? 0.7 : 1.0)
                        .offset(y: DeviceLayout.isSmallStatusBarPhone ? -50.scale : 0)

                        Spacer(minLength: bottomCardHeight + 40.scale)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                } else {
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)

                        Image(slide.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 375.scale, height: 450.scale)
                            .scaleEffect(DeviceLayout.isSmallStatusBarPhone ? 0.7 : 1.0)
                            .padding(.bottom, bottomCardHeight)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
    }
}
