//  PremiumStoreImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//

import Foundation
import Combine

final class PremiumStoreImpl: ObservableObject, PremiumStore {

    @Published var isPremium: Bool

    private let center: NotificationCenter
    private let defaults: UserDefaults
    private let premiumKey = "cb.premium.isActive.v1"

    init(
        center: NotificationCenter = .default,
        defaults: UserDefaults = .standard
    ) {
        self.center = center
        self.defaults = defaults

        
        self.isPremium = defaults.bool(forKey: premiumKey)

        
        center.addObserver(
            self,
            selector: #selector(onPremiumSynced(_:)),
            name: .cbPremiumSynced,
            object: nil
        )
    }

    deinit {
        center.removeObserver(self)
    }

    @objc private func onPremiumSynced(_ note: Notification) {
        guard let active = note.userInfo?["active"] as? Bool else { return }

        
        if isPremium != active {
            isPremium = active
        }
        defaults.set(active, forKey: premiumKey)
    }
}
