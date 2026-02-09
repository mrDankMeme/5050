//  AppDelegate.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/7/25.
//

import UIKit
import ApphudSDK
import AppTrackingTransparency
import AdSupport
import StoreKit
import AmplitudeUnified

final class AppDelegate: NSObject, UIApplicationDelegate {

    // MARK: - Analytics (Amplitude)
    private(set) var amplitude: Amplitude?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let amplitude = Amplitude(apiKey: "4f1b77403ce1df4b0eae78f86c9d221e")
        self.amplitude = amplitude
        amplitude.track(eventType: "app_launch", eventProperties: nil)

        Apphud.start(apiKey: "app_BrC9wtKArGzee3UzPSEtWduR1zomUi")

        Apphud.setDeviceIdentifiers(
            idfa: nil,
            idfv: UIDevice.current.identifierForVendor?.uuidString
        )

        fetchIDFA()

        let isActive = Apphud.hasActiveSubscription()
        
        UserDefaults.standard.set(isActive, forKey: "cb.premium.isActive.v1")

        NotificationCenter.default.post(
            name: .cbPremiumSynced,
            object: nil,
            userInfo: ["active": isActive]
        )

        SubscriptionProductsCache.shared.prefetch(
            ids: [
                "week_6.99_not_trial",
                "yearly_49.99_not_trial"
            ]
        )

        return true
    }

    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let isActive = Apphud.hasActiveSubscription()

        
        UserDefaults.standard.set(isActive, forKey: "cb.premium.isActive.v1")

        NotificationCenter.default.post(
            name: .cbPremiumSynced,
            object: nil,
            userInfo: ["active": isActive]
        )
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        amplitude?.track(eventType: "app_background", eventProperties: nil)
    }

    
    func applicationWillTerminate(_ application: UIApplication) {
        amplitude?.track(eventType: "app_terminate", eventProperties: nil)
    }

    // MARK: - ATT / IDFA prompt

    private func fetchIDFA() {
        guard #available(iOS 14.5, *) else { return }

        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard self != nil else { return }

            ATTrackingManager.requestTrackingAuthorization { status in
                guard status == .authorized else { return }

                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString

                
                DispatchQueue.main.async {
                    Apphud.setDeviceIdentifiers(
                        idfa: idfa,
                        idfv: UIDevice.current.identifierForVendor?.uuidString
                    )
                }
            }
        }
    }
}

// MARK: - Notifications

extension Notification.Name {
    /// Постится один раз на старте после Apphud.start(...)
    /// userInfo["active"] as? Bool == true, если есть активная подписка
    static let cbPremiumSynced = Notification.Name("cbPremiumSynced")
}
