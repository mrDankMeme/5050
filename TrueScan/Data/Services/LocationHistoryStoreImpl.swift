//
//  LocationHistoryStoreImpl.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/19/25.
//



import Foundation

final class LocationHistoryStoreImpl: LocationHistoryStore {

    private let key = "cb.location.history.v1"
    private let limit = 10
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - LocationHistoryStore

    var items: [LocationHistoryItem] {
        load()
    }

    func add(_ item: LocationHistoryItem) {
        var arr = load()

        if let thumb = item.thumbnailJPEG {
            let h = thumb.hashValue
            arr.removeAll {
                $0.title == item.title && ($0.thumbnailJPEG?.hashValue == h)
            }
        } else {
            arr.removeAll { $0.title == item.title }
        }

        // newest-first
        arr.insert(item, at: 0)

        // лимит
        if arr.count > limit {
            arr = Array(arr.prefix(limit))
        }

        save(arr)
    }

    func clear() {
        defaults.removeObject(forKey: key)
    }

    // MARK: - Private

    private func load() -> [LocationHistoryItem] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([LocationHistoryItem].self, from: data)) ?? []
    }

    private func save(_ arr: [LocationHistoryItem]) {
        if let data = try? JSONEncoder().encode(arr) {
            defaults.set(data, forKey: key)
        }
    }
}
