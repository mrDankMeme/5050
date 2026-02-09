//
//  CheaterViewModel.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import Foundation
import UIKit
import Combine

final class CheaterViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case previewImage(UIImage)
        case previewFile(name: String, data: Data)
        case uploading(progress: Int)
        case result(TaskResult)
        case error(String)

        static func == (lhs: State, rhs: State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle):
                return true
            case let (.previewImage(lImg), .previewImage(rImg)):
                return lImg.pngData() == rImg.pngData()
            case let (.previewFile(lName, lData), .previewFile(rName, rData)):
                return lName == rName && lData == rData
            case let (.uploading(l), .uploading(r)):
                return l == r
            case let (.result(l), .result(r)):
                return l == r
            case let (.error(l), .error(r)):
                return l == r
            default:
                return false
            }
        }
    }

    @Published var state: State = .idle

    private var lastKind: CheaterRecord.Kind?
    private var lastResult: TaskResult?

    
    
    private var lastImageJPEG: Data?

    private let auth: AuthRepository
    private let api: CheaterAPI
    private let poller: TaskPoller
    private let store: CheaterStore
    private let cfg: APIConfig

    private var currentAnalysisTask: Task<Void, Never>? = nil

    init(auth: AuthRepository, api: CheaterAPI, poller: TaskPoller, store: CheaterStore, cfg: APIConfig) {
        self.auth = auth
        self.api = api
        self.poller = poller
        self.store = store
        self.cfg = cfg
    }

    // MARK: - State helpers

    private func setState(_ newState: State) {
        if Thread.isMainThread {
            state = newState
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.state = newState
            }
        }
    }

    // MARK: - Public API

    func showImage(_ image: UIImage) {
        setState(.previewImage(image))
    }

    func showFile(name: String, data: Data) {
        setState(.previewFile(name: name, data: data))
    }

    func presentError(_ message: String) {
        setState(.error(message))
    }

    func cancelCurrentAnalysis() {
        currentAnalysisTask?.cancel()
        currentAnalysisTask = nil
    }

    func analyseCurrent(conversation: String? = nil, apphudId: String) {
        cancelCurrentAnalysis()

        
        Analytics.shared.track("cheater_analyze")

        currentAnalysisTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                try await self.auth.ensureAuthorized(apphudId: apphudId)

                
                
                switch self.state {
                case .previewImage(let img):
                    guard let data = img.jpegData(compressionQuality: 0.9) else {
                        throw APIError.noData
                    }
                    
                    self.lastImageJPEG = data

                    try await self.runTask(
                        files: [.init(
                            name: "files",
                            filename: "image.jpg",
                            mimeType: "image/jpeg",
                            data: data
                        )],
                        conversation: conversation,
                        kind: .image
                    )

                case .previewFile(let name, let data):
                    
                    self.lastImageJPEG = nil

                    try await self.runTask(
                        files: [.init(
                            name: "files",
                            filename: name,
                            mimeType: self.mime(for: name),
                            data: data
                        )],
                        conversation: conversation,
                        kind: .file
                    )

                default:
                    break
                }
            } catch {
                if Task.isCancelled { return }
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                self.presentError(message)
            }
        }
    }

    
    
    func saveToHistory(note: String? = "AI risk analysis") {
        guard let kind = lastKind, let r = lastResult else { return }
        
        store.add(.init(
            date: Date(),
            kind: kind,
            riskScore: r.risk_score,
            note: note,
            redFlags: r.red_flags,
            recommendations: r.recommendations,
            imageJPEG: (kind == .image ? lastImageJPEG : nil)
        ))
    }

    // MARK: - Private helpers

    private func mime(for filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "jpg", "jpeg":
            return "image/jpeg"
        case "png":
            return "image/png"
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }

    private func runTask(
        files: [MultipartFormData.FilePart],
        conversation: String?,
        kind: CheaterRecord.Kind
    ) async throws {
        if Task.isCancelled { return }
        setState(.uploading(progress: 10))

        let created = try await api.createAnalyzeTask(files: files, conversation: conversation)
        if Task.isCancelled { return }
        setState(.uploading(progress: 35))

        let final: TaskReadDTO
        switch created.status {
        case .finished, .failed:
            final = created
        default:
            final = try await poller.waitForAnalyzeResult(taskId: created.id, interval: 1.0)
        }
        if Task.isCancelled { return }

        switch final.status {
        case .finished:
            if case .details(let r)? = final.result {
                lastKind = kind
                lastResult = r
                setState(.result(r))
            } else if case .message(let msg)? = final.result {
                presentError(msg)
            } else {
                presentError("Empty result")
            }

        case .failed:
            presentError(final.error ?? "Analysis failed")

        default:
            presentError("Unexpected status: \(final.status)")
        }
    }
}
