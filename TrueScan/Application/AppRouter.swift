//  AppRouter.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation
import Combine

final class AppRouter: ObservableObject {

    enum Tab: Hashable {
        case search
        case cheater
        case history
        case settings
    }

    @Published var tab: Tab = .search
    @Published var historyPreferredSegment: HistoryViewModel.Segment = .search

    func openHistoryCheater() {
        historyPreferredSegment = .cheater
        tab = .history
    }

    func rememberHistorySegment(_ segment: HistoryViewModel.Segment) {
        historyPreferredSegment = segment
    }
}
