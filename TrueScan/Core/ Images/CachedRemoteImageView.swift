//
//  CachedRemoteImageView.swift
//  TrueScan
//


import SwiftUI
import UIKit

struct CachedRemoteImageView: View {

    let url: URL?
    let contentMode: SwiftUI.ContentMode
    var placeholder: AnyView

    init(
        url: URL?,
        contentMode: SwiftUI.ContentMode = .fill,
        placeholder: AnyView = AnyView(DefaultPlaceholder())
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = placeholder
    }

    @StateObject private var loader = Loader()

    var body: some View {
        Group {
            if let img = loader.image {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
            }
        }
        .onAppear {
            loader.loadIfNeeded(url: url)
        }
        .onChange(of: url?.absoluteString) { _, _ in
            loader.loadIfNeeded(url: url)
        }
    }
}

// MARK: - Loader

private final class Loader: ObservableObject {

    @Published var image: UIImage?

    private var currentURL: URL?
    private var task: Task<Void, Never>?

    func loadIfNeeded(url: URL?) {
        guard let url else {
            cancel()
            image = nil
            currentURL = nil
            return
        }

        if currentURL == url, image != nil { return }
        currentURL = url

        // 1) cache first (memory/disk)
        if let cached = RemoteImageCache.shared.image(for: url) {
            image = cached
            return
        }

        // 2) fetch
        cancel()
        image = nil

        task = Task { [weak self] in
            guard let self else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return }
                guard let img = UIImage(data: data) else { return }

                RemoteImageCache.shared.store(img, for: url)

                await MainActor.run {
                    if self.currentURL == url {
                        self.image = img
                    }
                }
            } catch {
                // ignore
            }
        }
    }

    private func cancel() {
        task?.cancel()
        task = nil
    }

    deinit {
        cancel()
    }
}

// MARK: - Default placeholder

private struct DefaultPlaceholder: View {
    var body: some View {
        ZStack {
            Color.white.opacity(0.001)
            Image(systemName: "photo")
                .font(.system(size: 12, weight: .regular))
                .foregroundStyle(Color.black.opacity(0.25))
        }
    }
}
