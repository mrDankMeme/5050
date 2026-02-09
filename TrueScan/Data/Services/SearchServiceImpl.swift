// Data/Services/Search/SearchServiceImpl.swift
// CheaterBuster
//
// MARK: - Swift 5 версия без strict concurrency-атрибутов

import Foundation
import Combine

final class SearchServiceImpl: SearchService {
    private let repo: SearchRepository
    private let poller: TaskPoller
    private let auth: AuthRepository

    #if DEBUG
    private static let useMockReverseSearch: Bool = false
    #endif

    init(repo: SearchRepository, poller: TaskPoller, auth: AuthRepository) {
        self.repo = repo
        self.poller = poller
        self.auth = auth
    }

    func searchByName(_ query: String) -> AnyPublisher<[ImageHit], Error> {
        Just(query)
            .delay(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .tryMap { q in
                let trimmed = q.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return [] }
                return (0..<6).map { i in
                    ImageHit(
                        title: "Result \(i+1) for '\(trimmed)'",
                        source: "example.com",
                        thumbnailURL: URL(string: "https://picsum.photos/seed/\(trimmed)\(i)/400/300"),
                        linkURL: URL(string: "https://example.com/\(i)")
                    )
                }
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Reverse Image Search

    func searchByImage(_ jpegData: Data) -> AnyPublisher<[ImageHit], Error> {
        #if DEBUG
        if Self.useMockReverseSearch {
            let hits = Self.makeMockHits(from: jpegData, count: 16)
            return Just(hits)
                .delay(for: .milliseconds(450), scheduler: DispatchQueue.main)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        #endif

        final class TaskHolder {
            var task: Task<Void, Never>?
        }
        let holder = TaskHolder()

        return Deferred {
            Future { promise in
                holder.task = Task {
                    do {
                        
                        let bid = Bundle.main.bundleIdentifier ?? "dev.cheaterbuster"
                        try await self.auth.ensureAuthorized(apphudId: "debug-\(bid)")
                        _ = try await self.auth.me()

                        
                        let taskId = try await self.repo.createReverseSearch(
                            image: jpegData,
                            filename: "image.jpg",
                            mimeType: "image/jpeg"
                        )

                        // Поллинг результата
                        let resp = try await self.poller.waitForReverseResult(
                            taskId: taskId,
                            interval: 15.0
                        )

                        let hits = Self.mapReverseResponseToHits(resp)
                        promise(.success(hits))
                    } catch is CancellationError {
                        promise(.failure(URLError(.cancelled)))
                    } catch {
                        #if DEBUG
                        print("⛔️ reverse-search failed: \(error)")
                        #endif
                        promise(.failure(error))
                    }
                }
            }
        }
        
        .handleEvents(receiveCancel: { holder.task?.cancel() })
        .eraseToAnyPublisher()
    }

    // MARK: - Мок-генератор
    private static func makeMockHits(from data: Data, count: Int) -> [ImageHit] {
        let seedBase = abs(Int(bitPattern: UInt(bitPattern: data.hashValue)))
        let sources = ["google", "yandex", "bing", "reddit", "pinterest", "instagram"]

        return (0..<count).map { i in
            let seed = "\(seedBase)_\(i)"

            let widths  = [320, 360, 400, 440, 480]
            let heights = [320, 360, 400, 440, 480]
            let w = widths[(seedBase + i) % widths.count]
            let h = heights[(seedBase / (i + 1) + i) % heights.count]

            let thumb = URL(string: "https://picsum.photos/seed/\(seed)/\(w)/\(h)")
            let link  = URL(string: "https://example.com/\(seed)")

            return ImageHit(
                title: "Similar match #\(i+1)",
                source: sources[i % sources.count],
                thumbnailURL: thumb,
                linkURL: link
            )
        }
    }

    // MARK: - Маппинг ответа -> [ImageHit]
    private static func mapReverseResponseToHits(_ resp: ReverseSearchGetResponse) -> [ImageHit] {
        var result: [ImageHit] = []

        if let g = resp.results.google?.visual_matches {
            for v in g {
                result.append(ImageHit(
                    title: v.title,
                    source: v.source,
                    thumbnailURL: v.thumbnail.flatMap(URL.init(string:)),
                    linkURL: URL(string: v.link)
                ))
            }
        }

        if let y = resp.results.yandex?.image_results {
            for v in y {
                result.append(ImageHit(
                    title: v.title,
                    source: v.source,
                    thumbnailURL: v.thumbnail?.link.flatMap(URL.init(string:)),
                    linkURL: URL(string: v.link)
                ))
            }
        }

        if let b = resp.results.bing?.related_content {
            for v in b {
                result.append(ImageHit(
                    title: v.title,
                    source: v.source ?? "bing",
                    thumbnailURL: v.thumbnail.flatMap(URL.init(string:)),
                    linkURL: URL(string: v.link)
                ))
            }
        }

        var seen = Set<String>()
        return result.filter { hit in
            let key = hit.linkURL?.absoluteString ?? ("\(hit.title)|\(hit.source)")
            if seen.contains(key) { return false }
            seen.insert(key)
            return true
        }
    }
}
