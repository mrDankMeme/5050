//  SettingsStoreImpl.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

final class SettingsStoreImpl: SettingsStore {
    private let key = "isHistoryEnabled"
    private let queue = DispatchQueue(label: "settings.store.queue", qos: .utility)

    var isHistoryEnabled: Bool {
        get {
            var result = true
            queue.sync {
                let defaults = UserDefaults.standard
                if defaults.object(forKey: key) == nil {
                    result = true
                } else {
                    result = defaults.bool(forKey: key)
                }
            }
            return result
        }
        set {
            queue.async {
                UserDefaults.standard.set(newValue, forKey: self.key)
            }
        }
    }
}
