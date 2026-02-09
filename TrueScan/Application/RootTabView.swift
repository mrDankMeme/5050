// Presentation/Root/RootTabView.swift
// CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import Swinject
import StoreKit
import UIKit

struct RootTabView: View {

    let isSplashActive: Bool

    @Environment(\.resolver) private var resolver
    @EnvironmentObject private var router: AppRouter
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("cb.hasOnboarded") private var hasOnboarded = false

    @State private var didRunFirstFlow = false
    @State private var showRateUs = false
    @State private var showInitialPaywall = false
    @State private var didPresentPaywallThisLaunch = false
    @State private var tabBarHeight: CGFloat = 0

    init(isSplashActive: Bool = false) {
        self.isSplashActive = isSplashActive
    }

    var body: some View {
        TabView(selection: $router.tab) {

            HomeView()
                .tabItem {
                    Label { Text("Home") } icon: { tabIcon("home") }
                }
                .tag(AppRouter.Tab.search)
                .background(
                    TabBarAccessor { bar in
                        let h = bar.bounds.height
                        if h > 0, h != tabBarHeight {
                            tabBarHeight = h
                        }
                    }
                )

            HistoryView(vm: resolver.resolve(HistoryViewModel.self)!)
                .tabItem {
                    Label { Text("History") } icon: { tabIcon("history") }
                }
                .tag(AppRouter.Tab.history)

            SettingsScreen(vm: SettingsViewModel(store: resolver.resolve(SettingsStore.self)!))
                .tabItem {
                    Label { Text("Settings") } icon: { tabIcon("settings") }
                }
                .tag(AppRouter.Tab.settings)
        }

        .environment(\.tabBarHeight, tabBarHeight)
        .tint(Tokens.Color.accent)
        .onAppear {
            configureTabAppearance()
        }

        // MARK: - Onboarding
        .fullScreenCover(
            isPresented: Binding(
                get: { hasOnboarded == false && isSplashActive == false },
                set: { if $0 == false { hasOnboarded = true } }
            )
        ) {
            let paywallVM = resolver.resolve(PaywallViewModel.self)!
            OnboardingView(paywallViewModel: paywallVM)
        }

        // MARK: - Rate Us (Feedback popup)
        .feedbackPopup(
            isPresented: $showRateUs,
            onBackgroundTap: {
                Analytics.shared.track("rateus_popup_dismiss_background")
                showRateUs = false
                RateUsScheduler.shared.customDismissed(positive: false)
                presentPaywallIfNotPremium(after: 0.35)
            }
        ) {
            FeedbackPopupView(
                model: .init(
                    title: "Was this analysis helpful?",
                    subtitle: "Your feedback helps us improve\nthe detection accuracy",
                    negativeAccessibilityLabel: "Not helpful",
                    positiveAccessibilityLabel: "Helpful"
                ),
                onDismiss: {
                    
                },
                onNegative: {
                    Analytics.shared.track("rateus_popup_negative")
                    showRateUs = false
                    RateUsScheduler.shared.customDismissed(positive: false)
                    presentPaywallIfNotPremium(after: 0.35)
                },
                onPositive: {
                    Analytics.shared.track("rateus_popup_positive")
                    showRateUs = false
                    RateUsScheduler.shared.customDismissed(positive: true)
                    presentPaywallIfNotPremium(after: 0.35)
                }
            )
        }

        // MARK: - Paywall
        .fullScreenCover(isPresented: $showInitialPaywall) {
            let vm = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: vm)
                .ignoresSafeArea()
        }

        // MARK: - First-run logic
        .onChange(of: hasOnboarded) { _, newValue in
            if newValue {
                triggerFirstRunFlowIfNeeded()
                requestTrackingIfNeeded()
            }
        }
        .task {
            if hasOnboarded {
                triggerFirstRunFlowIfNeeded()
                requestTrackingIfNeeded()
            }
            presentPaywallIfNeededOnLaunch()
        }

        // MARK: - Scene integration
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            presentPaywallIfNeededOnLaunch()
        }

        // MARK: - Scheduler → UI
        .onReceive(NotificationCenter.default.publisher(for: RateUsScheduler.willPresentCustomNotification)) { _ in
            DispatchQueue.main.async {
                guard hasOnboarded, showInitialPaywall == false else { return }
                showRateUs = true
            }
        }
    }

    // MARK: - Tab icons

    private func tabIcon(_ name: String) -> Image {
        let size = CGSize(width: 20.scale, height: 20.scale)

        guard let src = UIImage(named: name) else {
            return Image(name)
        }

        let tinted = src.withTintColor(.black, renderingMode: .alwaysOriginal)

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        format.scale = UIScreen.main.scale

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        let img = renderer.image { _ in
            UIColor.clear.setFill()
            UIRectFill(CGRect(origin: .zero, size: size))
            tinted.draw(in: CGRect(origin: .zero, size: size))
        }
        .withRenderingMode(.alwaysTemplate)

        return Image(uiImage: img)
    }

    // MARK: - Tab appearance (цвета + скруглённый фон)

    private func configureTabAppearance() {
        let activeColor = UIColor(Tokens.Color.accent)
        let inactiveColor = UIColor(Tokens.Color.textSecondary)
        let bgColor = UIColor.clear

        let tabBarProxy = UITabBar.appearance()
        tabBarProxy.backgroundImage = UIImage()
        tabBarProxy.shadowImage = UIImage()
        tabBarProxy.backgroundColor = bgColor
        tabBarProxy.isTranslucent = true

        tabBarProxy.tintColor = activeColor
        tabBarProxy.unselectedItemTintColor = inactiveColor

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = bgColor

            appearance.stackedLayoutAppearance.selected.iconColor = activeColor
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: activeColor
            ]

            appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: inactiveColor
            ]

            tabBarProxy.standardAppearance = appearance
            tabBarProxy.scrollEdgeAppearance = appearance
        }

        applyRoundedBackgroundToRealTabBar()
    }

    private func applyRoundedBackgroundToRealTabBar() {
        DispatchQueue.main.async {
            guard
                let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first,
                let window = windowScene.keyWindow
            else { return }

            let root = window.rootViewController
            let tabBarController = root as? UITabBarController
                ?? root?.children.compactMap { $0 as? UITabBarController }.first

            guard let tbc = tabBarController else { return }
            let tabBar = tbc.tabBar

            let horizontalInset: CGFloat = 0.scale
            let verticalInsetTop: CGFloat = 0.scale
            let verticalInsetBottom: CGFloat = 0.scale

            let bgTag = 987_654

            let backgroundView: UIView
            if let existing = tabBar.viewWithTag(bgTag) {
                backgroundView = existing
            } else {
                let view = UIView(frame: .zero)
                view.tag = bgTag
                tabBar.insertSubview(view, at: 0)
                backgroundView = view
            }

            let inset = UIEdgeInsets(
                top: verticalInsetTop,
                left: horizontalInset,
                bottom: verticalInsetBottom,
                right: horizontalInset
            )

            backgroundView.frame = tabBar.bounds.inset(by: inset)
            backgroundView.autoresizingMask = [
                .flexibleWidth,
                .flexibleHeight,
                .flexibleTopMargin
            ]

            backgroundView.backgroundColor = UIColor(Tokens.Color.surfaceCard)

            let radius: CGFloat = 32.scale
            backgroundView.layer.cornerRadius = radius

            backgroundView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]

            backgroundView.layer.masksToBounds = false

            backgroundView.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
            backgroundView.layer.shadowOpacity = 0.3
            backgroundView.layer.shadowOffset = CGSize(width: 0, height: -2.scale)
            backgroundView.layer.shadowRadius = 5.scale

            tabBar.clipsToBounds = false
            tabBar.layer.masksToBounds = false
        }
    }

    // MARK: - First run flow

    private func triggerFirstRunFlowIfNeeded() {
        guard didRunFirstFlow == false else { return }
        didRunFirstFlow = true

        let key = "cb.didShowRateThenPaywall.v1"
        guard UserDefaults.standard.bool(forKey: key) == false else { return }
        UserDefaults.standard.set(true, forKey: key)
    }

    private func requestTrackingIfNeeded() {
        let key = "cb.didAskATT.v1"
        guard UserDefaults.standard.bool(forKey: key) == false else { return }

        Task {
            if let pm = resolver.resolve(PermissionsManager.self) {
                _ = await pm.request(.tracking)
            }
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    // MARK: - Paywall on each launch

    private func presentPaywallIfNeededOnLaunch() { }

    private func presentPaywallIfNotPremium(after delay: Double = 0.0) {
        let isPremium = resolver.resolve(PremiumStore.self)?.isPremium ?? false
        guard isPremium == false else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            showInitialPaywall = true
        }
    }
}

struct RoundedCornersShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
