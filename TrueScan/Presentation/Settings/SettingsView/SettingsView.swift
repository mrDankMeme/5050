// Presentation/Settings/SettingsView/SettingsView.swift
//  SettingsScreen.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import Swinject
import StoreKit
import UIKit

struct SettingsScreen: View {
    @StateObject private var vm: SettingsViewModel

    @Environment(\.resolver) var resolver

    @State private var showPaywall = false
    @State private var showShareSheet = false
    @State var safariItem: SafariItem?

    @State var isRestoring = false
    @State var restoreError: String?

    // MARK: - App Lock
    @State private var showAppLockSheet = false

    // MARK: - App Lock
    @State private var showPasscodeSetup = false
    @State private var pendingModeAfterSetup: AppLockMode = .none

    init(vm: SettingsViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    private var isTabBarHidden: Bool {
        // Важно: fullScreenCover обычно и так перекрывает TabBar,
        // но мы делаем единый флаг, чтобы скрытие/возврат было анимированным и предсказуемым.
        showAppLockSheet || showPasscodeSetup || isRestoring
    }

    private var overlayAnim: Animation {
        .spring(response: 0.35, dampingFraction: 0.9)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Main content
                VStack(alignment: .leading, spacing: 0) {
                    SettingsHeaderView()
                 

                ScrollView {
                    VStack(spacing: Tokens.Spacing.x24) {
                        SettingsPremiumSection(
                            onGetPremium: {
                                // fullScreenCover, но оставляем нативное поведение
                                showPaywall = true
                            },
                            onRestore: restorePurchasesDirectly
                        )

                        SettingsInfoSection(
                            onSupport: sendSupportEmail,
                            onTerms: { openInApp(SettingsLinks.termsURL) },
                            onPrivacy: { openInApp(SettingsLinks.privacyURL) }
                        )

                        SettingsRateShareSection(
                            onRate: {
                                requestReviewInCurrentScene()
                            },
                            onShare: { showShareSheet = true }
                        )

                        // MARK: - Face ID & Passcode
                        SettingsAppLockSection(
                            onTap: {
                                withAnimation(overlayAnim) {
                                    showAppLockSheet = true
                                }
                            }
                        )
                    }
                    .padding(.horizontal, Tokens.Spacing.x16)
                    .padding(.top, Tokens.Spacing.x16)
                }
                }
                .background(Tokens.Color.backgroundMain.ignoresSafeArea())
                .toolbar(.hidden, for: .navigationBar)
                .toolbar(isTabBarHidden ? .hidden : .visible, for: .tabBar)
                .animation(overlayAnim, value: isTabBarHidden)

                // MARK: - Restore overlay
                if isRestoring {
                    SettingsRestoreOverlay()
                        .zIndex(500)
                }

                // MARK: - Dim (fade only) + Bottom sheet (slide)
                if showAppLockSheet {
                    // DIM: только fade, без "снизу вверх"
                    Color.black
                        .opacity(0.35)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .zIndex(900)
                        .onTapGesture {
                            withAnimation(overlayAnim) {
                                showAppLockSheet = false
                            }
                        }

                    // Bottom sheet: выезжает снизу
                    VStack {
                        Spacer(minLength: 0)

                        AppLockPickerOverlay(
                            onFaceID: {
                                // FaceID режим = требуем passcode (fallback)
                                pendingModeAfterSetup = .biometrics

                                if AppLockPrefs.hasPasscode() == false {
                                    withAnimation(overlayAnim) {
                                        showAppLockSheet = false
                                        showPasscodeSetup = true
                                    }
                                } else {
                                    AppLockPrefs.setLockMode(.biometrics)
                                    withAnimation(overlayAnim) {
                                        showAppLockSheet = false
                                    }
                                }
                            },
                            onPasscode: {
                                pendingModeAfterSetup = .passcode

                                if AppLockPrefs.hasPasscode() == false {
                                    withAnimation(overlayAnim) {
                                        showAppLockSheet = false
                                        showPasscodeSetup = true
                                    }
                                } else {
                                    AppLockPrefs.setLockMode(.passcode)
                                    withAnimation(overlayAnim) {
                                        showAppLockSheet = false
                                    }
                                }
                            },
                            onDismiss: {
                                withAnimation(overlayAnim) {
                                    showAppLockSheet = false
                                }
                            },
                            onChangePasscode: {
                                // просто меняем код без проверки старого (как ты просил — максимально просто)
                                pendingModeAfterSetup = AppLockPrefs.lockMode() == .none ? .passcode : AppLockPrefs.lockMode()
                                withAnimation(overlayAnim) {
                                    showAppLockSheet = false
                                    showPasscodeSetup = true
                                }
                            },
                            onTurnOff: {
                                AppLockPrefs.clearPasscode()
                                withAnimation(overlayAnim) {
                                    showAppLockSheet = false
                                }
                            }
                        )
                        .ignoresSafeArea()
                        .transition(.move(edge: .bottom))
                    }
                    .zIndex(1000)
                }
            }
            .animation(overlayAnim, value: showAppLockSheet)
        }
        .fullScreenCover(isPresented: $showPaywall) {
            let paywallVM = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: paywallVM).ignoresSafeArea()
        }
        .sheet(item: $safariItem) { item in
            SafariView(url: item.url)
                .ignoresSafeArea(edges: .bottom)
        }
        .fullScreenCover(isPresented: $showShareSheet) {
            ActivityView(activityItems: [SettingsLinks.shareText]).ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showPasscodeSetup) {
            PasscodeSetupView(
                title: "Set Passcode",
                onComplete: { code in
                    AppLockPrefs.setPasscode(code)
                    AppLockPrefs.setLockMode(pendingModeAfterSetup)
                    pendingModeAfterSetup = .none
                    withAnimation(overlayAnim) {
                        showPasscodeSetup = false
                    }
                },
                onCancel: {
                    pendingModeAfterSetup = .none
                    withAnimation(overlayAnim) {
                        showPasscodeSetup = false
                    }
                }
            )
        }
        .alert("Restore failed", isPresented: .constant(restoreError != nil)) {
            Button("OK", role: .cancel) { restoreError = nil }
        } message: {
            Text(restoreError ?? "")
        }
    }

    private func openInApp(_ url: URL) {
        safariItem = SafariItem(url: url)
    }
}
