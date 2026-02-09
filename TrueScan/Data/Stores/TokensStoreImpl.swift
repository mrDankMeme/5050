//
//  TokensStoreImpl.swift
//  CheaterBuster
//

import Foundation

final class TokensStoreImpl: TokensStore {
    private let key = "cb.tokens.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var tokens: Int {
        get { defaults.object(forKey: key) as? Int ?? 0 }
        set { defaults.set(newValue, forKey: key) }
    }
}
