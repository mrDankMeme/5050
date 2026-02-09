//  InMemoryTokenStorage.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

final class InMemoryTokenStorage: TokenStorage {

    private let q = DispatchQueue(label: "cb.tokens.inmemory")

    private var _accessToken: String?
    private var _userId: String?

    var accessToken: String? {
        get { q.sync { _accessToken } }
        set { q.sync { _accessToken = newValue } }
    }

    var userId: String? {
        get { q.sync { _userId } }
        set { q.sync { _userId = newValue } }
    }
}
