//  HistoryStore.swift
//  CheaterBuster

import Foundation
import Combine

public protocol HistoryStore {
    func load() -> [HistoryRecord]
    func add(_ record: HistoryRecord)
    func clearAll()
}
