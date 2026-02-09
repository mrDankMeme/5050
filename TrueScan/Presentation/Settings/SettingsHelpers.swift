//
//  SettingsHelpers.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//



import SwiftUI
import StoreKit
import UIKit

extension SettingsScreen {
    func restorePurchasesDirectly() {
        guard let subscription = resolver.resolve(SubscriptionService.self) else { return }
        isRestoring = true

        Task {
            do {
                try await subscription.restore()
                let generator = UINotificationFeedbackGenerator()
                DispatchQueue.main.async {
                    isRestoring = false
                    generator.notificationOccurred(.success)
                }
            } catch {
                let generator = UINotificationFeedbackGenerator()
                DispatchQueue.main.async {
                    isRestoring = false
                    restoreError = error.localizedDescription
                    generator.notificationOccurred(.error)
                }
            }
        }
    }

    func requestReviewInCurrentScene() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }) else { return }

        SKStoreReviewController.requestReview(in: scene)
    }

    func sendSupportEmail() {
        let userId = currentLocalUserId()
        let info = appInfoString(userId: userId)

        let subject = "CheaterBuster Support"
        let body = [
            "Hi!",
            "",
            "Please describe your issue here:",
            "",
            "-------------------------",
            info
        ].joined(separator: "\n")

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = SettingsLinks.supportEmail
        components.queryItems = [
            .init(name: "subject", value: subject),
            .init(name: "body", value: body)
        ]

        guard let url = components.url else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            safariItem = SafariItem(url: SettingsLinks.supportFormURL)
        }
    }

    func currentLocalUserId() -> String {
        let key = "cb.localUserId"
        if let existing = UserDefaults.standard.string(forKey: key) {
            return existing
        }
        let new = UUID().uuidString
        UserDefaults.standard.set(new, forKey: key)
        return new
    }

    func appInfoString(userId: String) -> String {
        let bundle = Bundle.main

        let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "CheaterBuster"

        let bundleId = bundle.bundleIdentifier ?? "unknown"
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"

        return """
        App: \(name)
        Bundle: \(bundleId)
        Version: \(version) (\(build))
        User ID: \(userId)
        Device: \(UIDevice.current.model)
        OS: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)
        """
    }
}
