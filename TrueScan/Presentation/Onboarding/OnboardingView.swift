// OnboardingView.swift

import SwiftUI
import StoreKit
import UIKit

struct OnboardingView: View {
    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false
    @State private var index: Int = 0
    @State private var didRequestSystemRateUs = false
    @ObservedObject private var paywallVM: PaywallViewModel
    @State private var safariItem: OnboardingSafariItem?

    private let slides: [OnboardingSlide] = OnboardingSlidesFactory.makeSlides()

    init(paywallViewModel: PaywallViewModel) {
        self._paywallVM = ObservedObject(wrappedValue: paywallViewModel)
    }

    private var currentSlide: OnboardingSlide? {
        guard index > 0, index <= slides.count else { return nil }
        return slides[index - 1]
    }

    private var currentArrayIndex: Int? {
        guard index > 0, index <= slides.count else { return nil }
        return index - 1
    }

    private var currentBottomCardHeight: CGFloat {
        guard let idx = currentArrayIndex else { return OnboardingLayout.bottomCardHeight }
        return idx == slides.count - 1 ? OnboardingLayout.lastStepBottomCardHeight : OnboardingLayout.bottomCardHeight
    }

    private func bottomCardHeight(forSlideAt offset: Int) -> CGFloat {
        offset == slides.count - 1 ? OnboardingLayout.lastStepBottomCardHeight : OnboardingLayout.bottomCardHeight
    }

    var body: some View {
        ZStack {
            if index <= slides.count {
                Tokens.Color.surfaceCard
                    .ignoresSafeArea()
            }

            if index == 0 {
                Image("onboarding_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160.scale, height: 160.scale)
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                index = 1
                            }
                        }
                    }
            } else {
                ZStack {
                    TabView(selection: $index) {
                        ForEach(Array(slides.enumerated()), id: \.offset) { offset, slide in
                            OnboardingSlideScreen(
                                slide: slide,
                                bottomCardHeight: bottomCardHeight(forSlideAt: offset)
                            )
                            .tag(offset + 1)
                        }

                        PaywallView(vm: paywallVM, isFromOnboarding: true)
                            .ignoresSafeArea()
                            .tag(slides.count + 1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))

                    if index <= slides.count {
                        VStack(spacing: 0) {
                            OnboardingStepProgress(current: min(index, slides.count), total: slides.count)
                                .padding(.horizontal, 16.scale)
                                .padding(.top, DeviceLayout.type == .smallStatusBar ? 30.scale : 60.scale)

                            Spacer()

                            if let slide = currentSlide {
                                OnboardingBottomCard(height: currentBottomCardHeight) {
                                    let baseTitleSize: CGFloat = 22.scale

                                    VStack(spacing: 16.scale) {
                                        VStack(spacing: 12.scale) {
                                            OnboardingTitleTextBuilder.titleText(
                                                title: slide.title,
                                                accentFragments: slide.accentFragment
                                            )
                                            .font(Tokens.Font.h2)
                                            .foregroundStyle(Tokens.Color.textPrimary)
                                            .multilineTextAlignment(.center)
                                            .lineSpacing((1.3 * baseTitleSize) - baseTitleSize)
                                            .kerning(-0.5)

                                            Text(slide.subtitle)
                                                .font(Tokens.Font.regular16)
                                                .foregroundStyle(Tokens.Color.textSecondary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(10_000)
                                                .kerning(-0.5)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }

                                        PrimaryButton("Continue") {
                                            handleContinueTap()
                                        }
                                        .buttonStyle(OpacityTapButtonStyle())

                                        HStack(spacing: 16.scale) {
                                            Button("Privacy Policy") {
                                                Analytics.shared.track("onboarding_privacy")
                                                openInApp(OnboardingLinks.privacyURL)
                                            }

                                            Button("Restore") {
                                                Analytics.shared.track("onboarding_restore")
                                                paywallVM.restore()
                                            }

                                            Button("Terms of Use") {
                                                Analytics.shared.track("onboarding_terms")
                                                openInApp(OnboardingLinks.termsURL)
                                            }
                                        }
                                        .font(Tokens.Font.medium12)
                                        .foregroundStyle(Tokens.Color.textSecondary.opacity(0.8))
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.top, 0.scale)
                                    }
                                    .padding(.horizontal, 20.scale)
                                    .animation(nil, value: index)
                                }
                                .padding(.horizontal, 0.scale)
                                .padding(.bottom, 0.scale)
                                .ignoresSafeArea(.container, edges: .bottom)
                            }
                        }
                        .ignoresSafeArea(.container, edges: .bottom)
                    }
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
        }
        .ignoresSafeArea(edges: .top)
        .onChange(of: index) { _, newValue in
            if newValue >= 1 && newValue <= slides.count {
                Analytics.shared.track("onboarding_step_\(newValue)_viewed")
            }

            if newValue == slides.count + 1 {
                Analytics.shared.track("onboarding_open_paywall")
            }

            guard newValue == slides.count, !didRequestSystemRateUs else { return }
            didRequestSystemRateUs = true

            _ = PaywallVideoPreloader.sharedAsset
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                requestSystemRateUs()
            }
        }
        .sheet(item: $safariItem) { item in
            OnboardingSafariView(url: item.url)
                .ignoresSafeArea(edges: .bottom)
        }
    }

    private func handleContinueTap() {
        guard let idx = currentArrayIndex else { return }

        Analytics.shared.track("onboarding_step_\(idx + 1)_continue")

        if idx == slides.count - 1 {
            withAnimation(.easeInOut(duration: 0.25)) {
                index = slides.count + 1
            }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                index = idx + 2
            }
        }
    }

    private func requestSystemRateUs() {
        guard
            let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
        else { return }

        SKStoreReviewController.requestReview(in: scene)
    }

    private func openInApp(_ url: URL) {
        safariItem = OnboardingSafariItem(url: url)
    }
}
