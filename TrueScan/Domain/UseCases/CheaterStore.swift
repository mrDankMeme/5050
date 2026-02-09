//  CheaterStore.swift
//  CheaterBuster

import Foundation

protocol CheaterStore {
    func load() -> [CheaterRecord]
    func add(_ record: CheaterRecord)
    func clearAll()
}
