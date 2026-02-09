//
//  AppLockStoreImpl.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

 

import Foundation

final class AppLockStoreImpl: AppLockStore {

    // MARK: - Keys

    private enum Keys {
        static let biometricsEnabled = "ts.applock.biometricsEnabled.v1"
        static let passcodeEnabled   = "ts.applock.passcodeEnabled.v1"
        static let passcodeHash      = "ts.applock.passcodeHash.v1"
    }

    // MARK: - Storage

    private let defaults: UserDefaults
    private let queue = DispatchQueue(label: "ts.applock.store.queue", qos: .utility)

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - AppLockStore

    var isBiometricsEnabled: Bool {
        get {
            queue.sync {
                defaults.bool(forKey: Keys.biometricsEnabled)
            }
        }
        set {
            queue.async {
                self.defaults.set(newValue, forKey: Keys.biometricsEnabled)
            }
        }
    }

    var isPasscodeEnabled: Bool {
        get {
            queue.sync {
                defaults.bool(forKey: Keys.passcodeEnabled)
            }
        }
        set {
            queue.async {
                self.defaults.set(newValue, forKey: Keys.passcodeEnabled)
            }
        }
    }

    var passcodeHash: String? {
        get {
            queue.sync {
                defaults.string(forKey: Keys.passcodeHash)
            }
        }
        set {
            queue.async {
                if let newValue {
                    self.defaults.set(newValue, forKey: Keys.passcodeHash)
                } else {
                    self.defaults.removeObject(forKey: Keys.passcodeHash)
                }
            }
        }
    }
}
