// CheaterBusterApp.swift
// CheaterBuster

import SwiftUI
import Swinject
import UIKit

@main
struct CheaterBusterApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    private let assembler = AppAssembler.make()
    private var resolver: Resolver { assembler.resolver }
    private var router: AppRouter { resolver.resolve(AppRouter.self)! }

#if DEBUG
    @State private var showDebugRateUs: Bool = false
    @State private var showDebugFeedbackPopup: Bool = false
#endif

    init() {
        ScreenScale.configure()

        UIWindow.appearance().overrideUserInterfaceStyle = .light
        UILabel.appearance().adjustsFontForContentSizeCategory = false
        UITextView.appearance().adjustsFontForContentSizeCategory = false
        UITextField.appearance().adjustsFontForContentSizeCategory = false
    }

    var body: some Scene {
        WindowGroup {
            RootContainerView()
                .environment(\.resolver, resolver)
                .environmentObject(router)
                .preferredColorScheme(.light)
#if DEBUG
                .task {
                    try? await Task.sleep(nanoseconds: 1000_000_000)
                    await MainActor.run {
                        showDebugFeedbackPopup = false
                         showDebugRateUs = false
                    }
                }

                .fullScreenCover(isPresented: $showDebugRateUs) {
                    RateUsView(
                        onLater: { showDebugRateUs = false },
                        onRated: { showDebugRateUs = false }
                    )
                    .ignoresSafeArea()
                }

                .feedbackPopup(
                    isPresented: $showDebugFeedbackPopup,
                    onBackgroundTap: {
                        showDebugFeedbackPopup = false
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
                            showDebugFeedbackPopup = false
                        },
                        onPositive: {
                            showDebugFeedbackPopup = false
                        }
                    )
                }
#endif
        }
    }
}
