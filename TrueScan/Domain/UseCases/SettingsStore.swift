//
//  SettingsStore.swift
//  CheaterBuster
//

import Foundation

public protocol SettingsStore: AnyObject {
    var isHistoryEnabled: Bool { get set }
}
