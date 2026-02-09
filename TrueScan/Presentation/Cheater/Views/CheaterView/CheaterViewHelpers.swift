//
//  CheaterViewHelpers.swift
//  CheaterBuster
//

import Foundation

enum CheaterViewHelpers {
    static func prettyErrorMessage(_ raw: String) -> String {
        if let data = raw.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let err = obj["error"] as? [String: Any],
               let msg = err["message"] as? String { return msg }
            if let msg = obj["message"] as? String { return msg }
        }
        return raw
    }
}
