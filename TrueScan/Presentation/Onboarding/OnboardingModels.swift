//
//  OnboardingModels.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//



import Foundation

struct OnboardingSlide: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let isFullScreenBackground: Bool
    let accentFragment: [String]?
}

enum OnboardingSlidesFactory {
    static func makeSlides() -> [OnboardingSlide] {
        [
            .init(
                imageName: "onboarding_1",
                title: "Find out who he really is",
                subtitle: "AI scans the internet and shows every place his photos appear.",
                isFullScreenBackground: false,
                accentFragment: ["who he really"]
            ),
            .init(
                imageName: "onboarding_2",
                title: "Detect red flags in messages",
                subtitle: "AI highlights red flags, lies, pressure and hidden intentions.",
                isFullScreenBackground: false,
                accentFragment: ["red flags"]
            ),
            .init(
                imageName: "onboarding_3",
                title: "See all his hidden profiles",
                subtitle: "AI finds every photo match and shows where else he appears.",
                isFullScreenBackground: false,
                accentFragment: ["hidden profiles"]
            ),
            .init(
                imageName: "onboarding_4",
                title: "You deserve the truth",
                subtitle: "Thousands of women use AI tools to protect their feelings and trust their intuition.",
                isFullScreenBackground: true,
                accentFragment: ["deserve", "truth"]
            )
        ]
    }
}
