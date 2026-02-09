// Data/Stores/CheaterStoreImpl.swift

import Foundation

final class CheaterStoreImpl: CheaterStore {
    private let key = "cb.cheater.history.v1"
    private let limit = 10
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [CheaterRecord] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([CheaterRecord].self, from: data)) ?? []
    }

    func add(_ record: CheaterRecord) {
        var arr = load()
        arr.insert(record, at: 0)
        if arr.count > limit {
            arr = Array(arr.prefix(limit))
        }
        save(arr)
    }

    func clearAll() {
        defaults.removeObject(forKey: key)
    }

    private func save(_ arr: [CheaterRecord]) {
        if let data = try? JSONEncoder().encode(arr) {
            defaults.set(data, forKey: key)
        }
    }
}
