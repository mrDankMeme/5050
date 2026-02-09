// Infrastructure/Security/KeychainTokenStorage.swift
// CheaterBuster
//
//  Created by Niiaz Khasanov on 11/6/25.
//

import Foundation
import Security


final class KeychainTokenStorage: TokenStorage {

    private let service: String
    private let q = DispatchQueue(label: "cb.keychain.tokenstorage")

    private let accountAccessToken = "cb.accessToken"
    private let accountUserId      = "cb.userId"

    private var _accessToken: String?
    private var _userId: String?

    init(service: String = Bundle.main.bundleIdentifier ?? "com.cheaterbuster.app") {
        self.service = service + ".auth"
        
        self._accessToken = KeychainTokenStorage.read(account: accountAccessToken, service: self.service)
        self._userId      = KeychainTokenStorage.read(account: accountUserId,      service: self.service)
    }

    // MARK: - TokenStorage

    var accessToken: String? {
        get { q.sync { _accessToken } }
        set {
            q.sync {
                _accessToken = newValue
                if let v = newValue {
                    KeychainTokenStorage.write(value: v, account: accountAccessToken, service: service)
                } else {
                    KeychainTokenStorage.delete(account: accountAccessToken, service: service)
                }
            }
        }
    }

    var userId: String? {
        get { q.sync { _userId } }
        set {
            q.sync {
                _userId = newValue
                if let v = newValue {
                    KeychainTokenStorage.write(value: v, account: accountUserId, service: service)
                } else {
                    KeychainTokenStorage.delete(account: accountUserId, service: service)
                }
            }
        }
    }

    // MARK: - Keychain helpers (static, чтобы не тянуть self)

    private static func query(account: String, service: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    private static func read(account: String, service: String) -> String? {
        var q = query(account: account, service: service)
        q[kSecReturnData as String] = kCFBooleanTrue
        q[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private static func write(value: String, account: String, service: String) {
        let data = Data(value.utf8)
        var q = query(account: account, service: service)

        let exists = (SecItemCopyMatching(q as CFDictionary, nil) == errSecSuccess)
        if exists {
            let attrs = [kSecValueData as String: data]
            _ = SecItemUpdate(q as CFDictionary, attrs as CFDictionary)
        } else {
            q[kSecValueData as String] = data
            q[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            _ = SecItemAdd(q as CFDictionary, nil)
        }
    }

    private static func delete(account: String, service: String) {
        let q = query(account: account, service: service)
        _ = SecItemDelete(q as CFDictionary)
    }
}
