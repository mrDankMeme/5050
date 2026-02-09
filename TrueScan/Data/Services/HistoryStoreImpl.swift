//
//  HistoryStoreImpl.swift
//  CheaterBuster
//

import Foundation
import UIKit

final class HistoryStoreImpl: HistoryStore {
    private let key = "cb.history.v1"
    private let limit = 10
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [HistoryRecord] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([HistoryRecord].self, from: data)) ?? []
    }

    func add(_ record: HistoryRecord) {
        var arr = load()

        if let q = record.query {
            arr.removeAll { $0.kind == .name && $0.query == q }
        } else if let data = record.imageJPEG {
            let h = data.hashValue
            arr.removeAll { $0.kind == .face && ($0.imageJPEG?.hashValue == h) }
        }

        arr.insert(record, at: 0)
        if arr.count > limit {
            arr = Array(arr.prefix(limit))
        }
        save(arr)
    }

    func clearAll() {
        defaults.removeObject(forKey: key)
    }

    private func save(_ arr: [HistoryRecord]) {
        if let data = try? JSONEncoder().encode(arr) {
            defaults.set(data, forKey: key)
        }
    }
}
