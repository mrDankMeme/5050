// Presentation/History/HistoryViewModel.swift
// CheaterBuster

import Foundation
import Combine
import UIKit

final class HistoryViewModel: ObservableObject {

    @Published private(set) var items: [HistoryRecord] = []
    @Published private(set) var cheaterItems: [CheaterRecord] = []
    @Published private(set) var locationItems: [LocationHistoryItem] = []

    @Published var segment: Segment = .search
    enum Segment: Equatable { case search, cheater, location }

    @Published private(set) var rerunResults: [ImageHit] = []
    @Published private(set) var isLoading = false
    @Published var errorText: String?

    @Published var selectedCheater: CheaterRecord?
    @Published var selectedLocation: LocationHistoryItem?   

    private let store: HistoryStore
    private let cheaterStore: CheaterStore
    private let locationStore: LocationHistoryStore
    private let search: SearchService

    private var inFlight: AnyCancellable?
    private var bag = Set<AnyCancellable>()

    init(
        store: HistoryStore,
        cheaterStore: CheaterStore,
        locationStore: LocationHistoryStore,
        search: SearchService
    ) {
        self.store = store
        self.cheaterStore = cheaterStore
        self.locationStore = locationStore
        self.search = search
        reload()
    }

    func reload() {
        items = store.load()
        cheaterItems = cheaterStore.load()

        locationItems = locationStore.items

        
        if locationItems.isEmpty {
            locationItems = makeMockLocationItems()
        }
    }

    func clearSearch() {
        cancelInFlight()
        store.clearAll()
        items = []
    }

    func clearCheater() {
        cheaterStore.clearAll()
        cheaterItems = []
    }

    func clearLocation() {
        locationStore.clear()
        locationItems = []
    }

    func cancelInFlight() {
        inFlight?.cancel()
        inFlight = nil
        isLoading = false
    }

    func onTapSearch(_ rec: HistoryRecord) {
        cancelInFlight()

        rerunResults = []
        isLoading = true
        errorText = nil

        let pub: AnyPublisher<[ImageHit], Error>

        if rec.kind == .name, let q = rec.query {
            pub = search.searchByName(q)
        } else if rec.kind == .face, let data = rec.imageJPEG {
            pub = search.searchByImage(data)
        } else {
            isLoading = false
            return
        }

        inFlight = pub
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink { [weak self] comp in
                guard let self else { return }
                self.isLoading = false

                if case .failure(let err) = comp {
                    if let urlErr = err as? URLError, urlErr.code == .cancelled {
                        self.errorText = nil
                    } else {
                        self.errorText = err.localizedDescription
                    }
                }
            } receiveValue: { [weak self] hits in
                self?.rerunResults = hits
            }
    }

    func onTapCheater(_ rec: CheaterRecord) {
        selectedCheater = rec
    }

    
    func onTapLocation(_ item: LocationHistoryItem) {
        selectedLocation = item
    }

    // MARK: - Mock (Step 4 legacy)

    private func makeMockLocationItems() -> [LocationHistoryItem] {
        return [
           
        ]
    }
}
