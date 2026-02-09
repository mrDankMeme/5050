// Presentation/Scenes/Search/SearchResultsView.swift
//
//  SearchResultsView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/26/25.
//

import SwiftUI
import UIKit
import WebKit

// MARK: - Web sheet item

private struct SearchResultWebItem: Identifiable, Equatable {
    let id = UUID()
    let url: URL
}

// MARK: - SearchResultsView

struct SearchResultsView: View {
    @ObservedObject var vm: SearchViewModel
    @Binding var path: [SearchScreen.Route]

    @State private var didSignalRateUs = false
    @State private var activeWebItem: SearchResultWebItem?

    private let itemSide: CGFloat = 167.5.scale
    private let gridSpacing: CGFloat = Tokens.Spacing.x16
    private let gridPadding: CGFloat = Tokens.Spacing.x16

    private var columns: [GridItem] {
        [
            GridItem(.fixed(itemSide), spacing: gridSpacing, alignment: .top),
            GridItem(.fixed(itemSide), spacing: gridSpacing, alignment: .top)
        ]
    }

    private var results: [ImageHit] { vm.results }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                header
                    .padding(.horizontal, gridPadding)
                    .padding(.top, 0.scale)
                    .padding(.bottom, Tokens.Spacing.x8)

                ScrollView {
                    if results.isEmpty {
                        ContentUnavailableView(
                            "No results found",
                            systemImage: "magnifyingglass.circle",
                            description: Text("No matches found. Please try a different photo.")
                        )
                        .padding(.top, Tokens.Spacing.x24)
                    } else {
                        LazyVGrid(columns: columns, spacing: gridSpacing) {
                            ForEach(results) { hit in
                                SearchResultTile(
                                    hit: hit,
                                    cardSide: itemSide,
                                    onOpen: { openWeb(on: hit) }
                                )
                                .onTapGesture { openWeb(on: hit) }
                                .onLongPressGesture { openWeb(on: hit) } // как было у тебя
                            }
                        }
                        .padding(.horizontal, gridPadding)
                        .padding(.vertical, Tokens.Spacing.x24)
                        .animation(.easeInOut(duration: 0.25), value: results.count)
                    }
                }
                .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            guard !vm.results.isEmpty, !didSignalRateUs else { return }
            didSignalRateUs = true
            RateUsScheduler.shared.requestCustom(.searchResults)
        }
        .sheet(item: $activeWebItem) { item in
            SearchResultWebSheet(
                url: item.url,
                onClose: { activeWebItem = nil }
            )
            .ignoresSafeArea()
        }
    }

    private var header: some View {
        HStack {
            BackButton(size: 44.scale) { _ = path.popLast() }

            Spacer()

            Text("Face results")
                .font(Tokens.Font.bodyMedium18)
                .foregroundStyle(Tokens.Color.textPrimary)

            Spacer()

            Color.clear.frame(width: 44.scale, height: 44.scale)
        }
    }

    private func openWeb(on hit: ImageHit) {
        guard let url = hit.linkURL else { return }
        Analytics.shared.track("search_results_open_webview")
        activeWebItem = SearchResultWebItem(url: url)
    }
}

// MARK: - Search result tile (как SearchTile: white card + hard shadow)

private struct SearchResultTile: View {
    let hit: ImageHit
    let cardSide: CGFloat
    let onOpen: () -> Void

    // Match SearchTile design
    private let cardCorner: CGFloat = 16.scale
    private let imageCorner: CGFloat = 8.scale
    private let innerPadding: CGFloat = 8.scale
    private let textTopSpacing: CGFloat = Tokens.Spacing.x8.scale
    private let badgePadding: CGFloat = 10.scale

    private var imageSide: CGFloat {
        max(1, cardSide - innerPadding * 2)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cardCorner, style: .continuous)
                .fill(Color.white)
                .compositingGroup()
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 4.scale,
                    y: 4.scale
                )

            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomTrailing) {
                    CachedThumb(url: hit.thumbnailURL)
                        .frame(width: imageSide, height: imageSide)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: imageCorner, style: .continuous))

                    if let badgeURL = SiteBadgeURLResolver.resolve(
                        iconURLString: hit.sourceIconURL?.absoluteString,
                        linkURLString: hit.linkURL?.absoluteString,
                        previewText: hit.source
                    ) {
                        SiteBadgeIcon(url: badgeURL)
                            .padding(badgePadding)
                            .allowsHitTesting(false)
                            .accessibilityIdentifier("searchResults.siteBadge")
                    }
                }
                .padding(.top, innerPadding)
                .padding(.horizontal, innerPadding)

                Spacer(minLength: textTopSpacing)

                Text(hit.title)
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, innerPadding)
                    .padding(.bottom, innerPadding)
            }
        }
        .frame(width: cardSide)
        .contentShape(RoundedRectangle(cornerRadius: cardCorner, style: .continuous))
    }
}

// MARK: - CachedThumb — превью через memory+disk cache (без мигания)

private struct CachedThumb: View {
    let url: URL?

    var body: some View {
        CachedRemoteImageView(
            url: url,
            contentMode: .fill,
            placeholder: AnyView(Placeholder())
        )
        .clipped()
    }

    private struct Placeholder: View {
        var body: some View {
            ZStack {
                Tokens.Color.surfaceCard
                Image(systemName: "photo")
                    .font(.system(size: 14.scale, weight: .regular))
                    .foregroundStyle(Tokens.Color.textSecondary.opacity(0.35))
            }
        }
    }
}

// MARK: - Web sheet контейнер с хедером

private struct SearchResultWebSheet: View {
    let url: URL
    let onClose: () -> Void

    @State private var isLoading: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .background(Tokens.Color.borderNeutral.opacity(0.4))

            ZStack {
                SearchResultWebView(url: url, isLoading: $isLoading)
                    .id(url)
                    .edgesIgnoringSafeArea(.bottom)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(12.scale)
                        .background(
                            Tokens.Color.surfaceCard,
                            in: RoundedRectangle(cornerRadius: 12.scale, style: .continuous)
                        )
                        .apply(Tokens.Shadow.card)
                }
            }
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 12.scale) {
            Button(action: onClose) {
                Text("Close")
                    .font(Tokens.Font.medium16)
                    .foregroundStyle(Tokens.Color.textPrimary)
            }

            Text(url.absoluteString)
                .font(Tokens.Font.medium12)
                .foregroundStyle(Tokens.Color.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16.scale)
        .padding(.vertical, 12.scale)
        .background(Tokens.Color.backgroundMain)
    }
}

// MARK: - WKWebView wrapper

private struct SearchResultWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    func makeCoordinator() -> Coordinator { Coordinator(isLoading: $isLoading) }

    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView(frame: .zero)
        view.navigationDelegate = context.coordinator
        view.allowsBackForwardNavigationGestures = true

        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )
        view.load(request)
        return view
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.navigationDelegate = context.coordinator

        if uiView.url != url {
            let request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalCacheData,
                timeoutInterval: 30
            )
            uiView.load(request)
        }
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding var isLoading: Bool

        init(isLoading: Binding<Bool>) {
            _isLoading = isLoading
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            isLoading = true
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            isLoading = false
        }
    }
}
