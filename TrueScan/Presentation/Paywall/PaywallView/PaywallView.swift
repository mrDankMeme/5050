//  PaywallView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


import SwiftUI
import StoreKit
import SafariServices
import AVFoundation

struct PaywallView: View {
    @ObservedObject var vm: PaywallViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showCloseButton = false
    let isFromOnboarding: Bool

    init(vm: PaywallViewModel, isFromOnboarding: Bool = false) {
        self.vm = vm
        self.isFromOnboarding = isFromOnboarding
    }

    private let termsURL = URL(string: "https://docs.google.com/document/d/1q_xeLX-8INjWq2-o82a3E0bHGR8aSddn_SbCQrzcaao/edit?usp=sharing")!
    private let privacyURL = URL(string: "https://docs.google.com/document/d/1WPlsj7Ny5dL5gmUSHBpOQwh4sImedr7vyZFlDpMfJKU/edit?usp=sharing")!

    private let weeklyID = "week_6.99_not_trial"
    private let yearlyID = "yearly_49.99_not_trial"

    @State private var weeklyTitle: String = ""
    @State private var yearlyTitle: String = ""
    @State private var yearlySubtitle: String?
    @State private var yearlyBadge: String?

    @State private var weeklyTrailingPrice: String = ""
    @State private var yearlyTrailingPrice: String = ""

    @State private var hasPrices: Bool = false
    @State private var isDebugMockPrices: Bool = false

    @State private var weeklyProduct: Product?
    @State private var yearlyProduct: Product?

    @State private var safariItem: SafariItem?

    private let features: [FeatureItem] = [
        .init(imageName: "heartSearch", title: "Find him by photo", subtitle: "AI scans the internet for matching profiles."),
        .init(imageName: "glass", title: "Spot red flags instantly", subtitle: "AI detects manipulation and suspicious behavior."),
        .init(imageName: "unlimited", title: "Unlimited searches", subtitle: "Unlock full access to all AI tools and future updates.")
    ]

    var body: some View {
        GeometryReader { rootGeo in
            ZStack {
                let isSmallStatusBar = DeviceLayout.type == .smallStatusBar

                PaywallVideoBackgroundView()
                    .ignoresSafeArea()
                    .offset(y: isSmallStatusBar ? -245.scale : -200.scale)

                VStack(spacing: 8.scale) {
                    Spacer()

                    VStack(spacing: 0) {
                        Text("Unlock the full power of AI")
                            .font(Tokens.Font.subtitle)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, Tokens.Spacing.x16 * 3)
                            .padding(.top, topSafeInset + Tokens.Spacing.x16)

                        PaywallFeaturePager(items: features, selectedIndex: $vm.featureIndex)
                            .padding(.top, 0)
                    }
                    .padding(.bottom, -10.scale)

                    ZStack(alignment: .top) {
                        UnevenRoundedRectangle(
                            topLeadingRadius: 32.scale,
                            bottomLeadingRadius: 0.scale,
                            bottomTrailingRadius: 0.scale,
                            topTrailingRadius: 32.scale
                        )
                        .fill(Tokens.Color.backgroundMain)
                        .shadow(color: .black.opacity(0.08), radius: 16.scale, y: -2.scale)

                        VStack(spacing: 0) {
                            VStack(spacing: Tokens.Spacing.x16) {
                                PaywallPlanRowView(
                                    title: weeklyTitle,
                                    subtitle: nil,
                                    trailingPrice: weeklyTrailingPrice,
                                    selected: vm.selected == .weekly,
                                    highlighted: false,
                                    badge: nil,
                                    fixedHeight: 64.scale,
                                    isLoaded: hasPrices
                                ) { vm.selected = .weekly }

                                PaywallPlanRowView(
                                    title: yearlyTitle,
                                    subtitle: yearlySubtitle,
                                    trailingPrice: yearlyTrailingPrice,
                                    selected: vm.selected == .yearly,
                                    highlighted: true,
                                    badge: yearlyBadge,
                                    fixedHeight: 64.scale,
                                    isLoaded: hasPrices
                                ) { vm.selected = .yearly }
                            }
                            .padding(.horizontal, Tokens.Spacing.x16)
                            .padding(.top, Tokens.Spacing.x20)

                            Text("Cancel at any time")
                                .font(Tokens.Font.medium12)
                                .foregroundStyle(Tokens.Color.textSecondary)
                                .padding(.top, Tokens.Spacing.x16)

                            PrimaryButton(
                                vm.isProcessing ? "Processing..." : "Continue",
                                isLoading: vm.isProcessing,
                                isDisabled: vm.isProcessing || !hasPrices
                            ) {
                                Analytics.shared.track("Sub pay")
                                vm.buy()
                            }
                            .buttonStyle(OpacityTapButtonStyle())
                            .padding(.horizontal, Tokens.Spacing.x16)
                            .padding(.top, Tokens.Spacing.x8)

                            HStack(spacing: 16.scale) {
                                Button("Privacy Policy") { openInApp(privacyURL) }
                                    .buttonStyle(OpacityTapButtonStyle())
                                    .font(Tokens.Font.medium12)

                                Button("Restore") { vm.restore() }
                                    .buttonStyle(OpacityTapButtonStyle())
                                    .font(Tokens.Font.medium12)

                                Button("Terms of Use") { openInApp(termsURL) }
                                    .buttonStyle(OpacityTapButtonStyle())
                                    .font(Tokens.Font.medium12)
                            }
                            .font(Tokens.Font.caption)
                            .foregroundStyle(Tokens.Color.textSecondary.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, Tokens.Spacing.x16 * 1.5)
                            .padding(.top, Tokens.Spacing.x12)
                            .padding(.bottom, rootGeo.safeAreaInsets.bottom + Tokens.Spacing.x8)
                        }
                    }
                    .frame(height: 320.scale)
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
            }
            .overlay(alignment: .topTrailing) {
                if showCloseButton {
                    Button { dismiss() } label: {
                        Image("xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32.scale, height: 32.scale)
                            .opacity(0.3)
                            .foregroundStyle(Color(hex: "#141414"))
                            .padding(.trailing, Tokens.Spacing.x16)
                            .padding(.top, topSafeInset)
                    }
                    .buttonStyle(OpacityTapButtonStyle())
                    .transition(.opacity)
                }
            }
            .alert("Error", isPresented: .constant(vm.errorText != nil), actions: {
                Button("OK") { vm.errorText = nil }.buttonStyle(OpacityTapButtonStyle())
            }, message: { Text(vm.errorText ?? "") })
            .onChange(of: vm.didFinish) { _, done in
                if done { dismiss() }
            }
            .task {
                if hasPrices { return }

                if let w = SubscriptionProductsCache.shared.product(id: weeklyID),
                   let y = SubscriptionProductsCache.shared.product(id: yearlyID) {
                    applyPrice(weekly: w, yearly: y)
                    isDebugMockPrices = false
                    hasPrices = true
                    return
                }

                await loadPricesFromStoreKit()
            }
            .task {
                guard !showCloseButton else { return }
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 0.25)) { showCloseButton = true }
                }
            }
            .onAppear { ApphudPaywallTracker.trackShown() }
            .sheet(item: $safariItem) { item in
                SafariView(url: item.url).ignoresSafeArea(edges: .bottom)
            }
        }
    }

    private func openInApp(_ url: URL) {
        safariItem = SafariItem(url: url)
    }

    private func loadPricesFromStoreKit() async {
        if hasPrices { return }

        do {
            let products = try await Product.products(for: [weeklyID, yearlyID])
            weeklyProduct = products.first(where: { $0.id == weeklyID })
            yearlyProduct = products.first(where: { $0.id == yearlyID })

            if let w = weeklyProduct, let y = yearlyProduct {
                applyPrice(weekly: w, yearly: y)
                isDebugMockPrices = false
                hasPrices = true
            } else {
#if DEBUG
                applyDebugMockPrices()
#endif
            }
        } catch {
#if DEBUG
            applyDebugMockPrices()
#endif
        }
    }

    private func applyPrice(weekly: Product, yearly: Product) {
        weeklyTitle = "Weekly"
        yearlyTitle = "Yearly"

        let weeklyDec: Decimal = weekly.price
        let yearlyDec: Decimal = yearly.price

        weeklyTrailingPrice = weekly.displayPrice
        yearlySubtitle = "just \(yearly.displayPrice)/year"

        let weeklyFormat = weekly.priceFormatStyle
        let perWeekDec: Decimal = yearlyDec / Decimal(52)
        let perWeekString: String = perWeekDec.formatted(weeklyFormat)
        yearlyTrailingPrice = "\(perWeekString)/week"

        let weeklyYear: Decimal = weeklyDec * Decimal(52)
        if weeklyYear > .zero {
            let ratio: Decimal = yearlyDec / weeklyYear
            let save: Decimal = max(.zero, Decimal(1) - ratio)

            let saveTimes100 = (save as NSDecimalNumber).multiplying(by: 100)
            let percent = Int(truncating: saveTimes100.rounding(accordingToBehavior:
                NSDecimalNumberHandler(
                    roundingMode: .down,
                    scale: 0,
                    raiseOnExactness: false,
                    raiseOnOverflow: false,
                    raiseOnUnderflow: false,
                    raiseOnDivideByZero: false
                )
            ))
            let clamped = max(0, min(percent, 99))
            yearlyBadge = clamped > 0 ? "Save \(clamped)%" : nil
        } else {
            yearlyBadge = nil
        }
    }

#if DEBUG
    private func applyDebugMockPrices() {
        weeklyTitle = "Weekly"
        weeklyTrailingPrice = "$4.99"

        yearlyTitle = "Yearly"
        yearlySubtitle = "just $39.99/year"
        yearlyTrailingPrice = "$2/week"
        yearlyBadge = "Debug"

        isDebugMockPrices = true
        hasPrices = true
    }
#endif
}
