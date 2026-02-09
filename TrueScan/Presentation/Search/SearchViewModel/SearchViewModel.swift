//
//  SearchViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import Combine
import UIKit

final class SearchViewModel: ObservableObject {

    // MARK: - Output
    @Published var results: [ImageHit] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isBlockingLoading: Bool = false
    @Published private(set) var errorText: String?

    // MARK: - Deps
    private let search: SearchService
    private let history: HistoryStore
    private let settings: SettingsStore?

    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    init(search: SearchService,
         history: HistoryStore,
         settings: SettingsStore? = nil)
    {
        self.search = search
        self.history = history
        self.settings = settings
    }

    func runImageSearch(jpegData: Data) {

        bag.forEach { $0.cancel() }
        bag.removeAll()

        isLoading = true
        isBlockingLoading = true
        errorText = nil

        search.searchByImage(jpegData)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.isBlockingLoading = false
                if case .failure(let err) = completion {
                    self.errorText = err.localizedDescription
                    self.results = []
                }
            } receiveValue: { [weak self] hits in
                guard let self else { return }
                self.results = hits

                let thumbData = (UIImage(data: jpegData)?
                    .jpegData(compressionQuality: 0.5)) ?? jpegData

                let first = hits.first
                let rec = HistoryRecord(
                    kind: .face,
                    query: nil,
                    imageJPEG: thumbData,
                    titlePreview: first?.title,
                    sourcePreview: first?.source,
                    // ✅ NEW: сохраняем в History
                    sourceIconURL: first?.sourceIconURL?.absoluteString,
                    sourceLinkURL: first?.linkURL?.absoluteString
                )
                self.history.add(rec)
            }
            .store(in: &bag)
    }

    func resetResults() {
        results = []
        errorText = nil
    }
}
