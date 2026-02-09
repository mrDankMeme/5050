//
//  SettingsViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var isHistoryEnabled: Bool {
        didSet { store.isHistoryEnabled = isHistoryEnabled }
    }

    private var store: SettingsStore

    init(store: SettingsStore) {
        self.store = store
        self.isHistoryEnabled = store.isHistoryEnabled
    }
}
