// Presentation/FindAPlace/FindAPlaceViewModel/FindPlaceViewModel.swift
// TrueScan

import Foundation
import UIKit

final class FindPlaceViewModel: ObservableObject {

    // MARK: - State

    enum State: Equatable {
        case upload
        case previewImage(UIImage)
        case previewFile(name: String, data: Data)
        case uploading(progress: Int)
        case result(String)
        case error(String)
    }

    @Published private(set) var state: State = .upload

    // MARK: - Dependencies

    private let auth: AuthRepository
    private let api: CheaterAPI
    private let poller: TaskPoller
    private let cfg: APIConfig

    private var currentAnalysisTask: Task<Void, Never>? = nil

    // MARK: - Init

    init(
        auth: AuthRepository,
        api: CheaterAPI,
        poller: TaskPoller,
        cfg: APIConfig
    ) {
        self.auth = auth
        self.api = api
        self.poller = poller
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

    // MARK: - Public API (UI -> VM)

    func showImage(_ image: UIImage) {
        setState(.previewImage(image))
    }

    func showFile(name: String, data: Data) {
        setState(.previewFile(name: name, data: data))
    }

    func goBackToUpload() {
        setState(.upload)
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

        Analytics.shared.track("findplace_analyze")

        currentAnalysisTask = Task { [weak self] in
            guard let self = self else { return }

            do {
                try await self.auth.ensureAuthorized(apphudId: apphudId)

                
                let image: UIImage?

                switch self.state {
                case .previewImage(let img):
                    image = img

                case .previewFile(_, let data):
                    
                    image = UIImage(data: data)

                default:
                    image = nil
                }

                guard let img = image else {
                    throw APIError.noData
                }

                guard let jpeg = img.jpegData(compressionQuality: 0.9) else {
                    throw APIError.noData
                }

                try await self.runPlaceTask(
                    file: .init(
                        name: "file",
                        filename: "image.jpg",
                        mimeType: "image/jpeg",
                        data: jpeg
                    ),
                    conversation: conversation
                )

            } catch {
                if Task.isCancelled { return }
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                self.presentError(message)
            }
        }
    }

    // MARK: - Private

    private func runPlaceTask(
        file: MultipartFormData.FilePart,
        conversation: String?
    ) async throws {
        if Task.isCancelled { return }
        setState(.uploading(progress: 10))

        let created = try await api.createAnalyzePlaceTask(file: file, conversation: conversation)

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
    
            if case .message(let msg)? = final.result {
                setState(.result(msg))
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
