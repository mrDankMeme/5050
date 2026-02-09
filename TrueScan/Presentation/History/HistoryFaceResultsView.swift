// Presentation/History/HistoryFaceResultsView.swift
//
//  HistoryFaceResultsView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 11/3/25.
//

import SwiftUI
import UIKit
import WebKit

// MARK: - Web sheet item (для History)

private struct HistoryWebItem: Identifiable, Equatable {
    let id = UUID()
    let url: URL
}

struct HistoryFaceResultsView: View {

    let hits: [ImageHit]

    private var top10: [ImageHit] {
        Array(hits.prefix(10))
    }

    // Жёсткая сетка 2 x 167.5.scale
    private let itemSide: CGFloat = 167.5.scale
    private let gridSpacing: CGFloat = Tokens.Spacing.x16
    private let gridPadding: CGFloat = Tokens.Spacing.x16

    private var columns: [GridItem] {
        [
            GridItem(.fixed(itemSide), spacing: gridSpacing, alignment: .top),
            GridItem(.fixed(itemSide), spacing: gridSpacing, alignment: .top)
        ]
    }

    @Environment(\.dismiss) private var dismiss

    @State private var showCopyToast: Bool = false
    private let toastDismissDelay: TimeInterval = 1.8

    // WebView sheet state
    @State private var activeWebItem: HistoryWebItem?

    var body: some View {
        ZStack {
            VStack(spacing: 0) {

                HStack {
                    BackButton(size: 44.scale) { dismiss() }
                        .buttonStyle(OpacityTapButtonStyle())

                    Spacer()

                    Text("Face results")
                        .font(Tokens.Font.bodyMedium18)
                        .foregroundStyle(Tokens.Color.textPrimary)

                    Spacer()

                    Color.clear.frame(width: 44.scale, height: 44.scale)
                }
                .padding(.horizontal, gridPadding)
                .padding(.top, 0.scale)
                .padding(.bottom, Tokens.Spacing.x8)

                ScrollView {
                    if top10.isEmpty {
                        ContentUnavailableView(
                            "No results found",
                            systemImage: "magnifyingglass.circle",
                            description: Text("No matches found. Please try a different photo.")
                        )
                        .padding(.top, Tokens.Spacing.x24)
                    } else {
                        LazyVGrid(columns: columns, spacing: gridSpacing) {
                            ForEach(top10) { hit in
                                ResultCard(
                                    hit: hit,
                                    side: itemSide,
                                    onOpen: { openWeb(on: hit) },
                                    onCopy: { copyLink(of: hit) }
                                )
                            }
                        }
                        .padding(.horizontal, gridPadding)
                        .padding(.vertical, Tokens.Spacing.x24)
                    }
                }
                .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            }

            if showCopyToast {
                VStack {
                    Spacer()
                    CopyToastView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 40.scale)
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.9), value: showCopyToast)
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(item: $activeWebItem) { item in
            HistoryResultWebSheet(
                url: item.url,
                onClose: { activeWebItem = nil }
            )
            .ignoresSafeArea()
        }
    }

    private func openWeb(on hit: ImageHit) {
        guard let url = hit.linkURL else { return }
        Analytics.shared.track("history_face_results_open_webview")
        activeWebItem = HistoryWebItem(url: url)
    }

    private func copyLink(of hit: ImageHit) {
        guard let url = hit.linkURL else { return }
        UIPasteboard.general.string = url.absoluteString

        withAnimation {
            showCopyToast = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + toastDismissDelay) {
            withAnimation {
                showCopyToast = false
            }
        }
    }
}

// MARK: - Card (NEW design: like SearchTile)

private struct ResultCard: View {
    let hit: ImageHit
    let side: CGFloat
    let onOpen: () -> Void
    let onCopy: () -> Void

    // Требования из твоего сообщения:
    // - Отступ от края картинки до подложки = 8
    // - corner картинки = 8
    // - corner подложки = 16
    private let cardCorner: CGFloat = 16
    private let imageCorner: CGFloat = 8
    private let innerPadding: CGFloat = 8
    private let badgePadding: CGFloat = 10

    private let textTopSpacing: CGFloat = Tokens.Spacing.x8.scale

    var body: some View {
        // Белая карточка + жёсткая тень
        ZStack {
            RoundedRectangle(cornerRadius: cardCorner.scale, style: .continuous)
                .fill(Color.white)
                .compositingGroup()
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 4.scale,
                    y: 4.scale
                )

            VStack(alignment: .leading, spacing: textTopSpacing) {
                // Картинка внутри с отступами 8
                let imageSide = max(1, side - innerPadding.scale * 2)

                ZStack(alignment: .bottomTrailing) {
                    CachedRemoteImageView(
                        url: hit.thumbnailURL,
                        contentMode: .fill,
                        placeholder: AnyView(Placeholder())
                    )
                    .frame(width: imageSide, height: imageSide)
                    .clipped()
                    .clipShape(
                        RoundedRectangle(cornerRadius: imageCorner.scale, style: .continuous)
                    )

                    // Бейдж сайта (как и было)
                    if let badgeURL = SiteBadgeURLResolver.resolve(
                        iconURLString: hit.sourceIconURL?.absoluteString,
                        linkURLString: hit.linkURL?.absoluteString,
                        previewText: hit.source
                    ) {
                        SiteBadgeIcon(url: badgeURL)
                            .padding(badgePadding.scale)
                            .allowsHitTesting(false)
                            .accessibilityIdentifier("historyFaceResults.siteBadge")
                    }
                }
                .padding(.top, innerPadding.scale)
                .padding(.horizontal, innerPadding.scale)

                // Подпись внутри карточки снизу
                Text(hit.title)
                    .font(Tokens.Font.caption)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, innerPadding.scale)
                    .padding(.bottom, innerPadding.scale)
            }
        }
        .frame(width: side) // важно: фиксируем ширину под сетку
        .contentShape(
            RoundedRectangle(cornerRadius: cardCorner.scale, style: .continuous)
        )
        .onTapGesture { onOpen() }
        .onLongPressGesture { onCopy() }
    }
}

// MARK: - Placeholder

private struct Placeholder: View {
    var body: some View {
        ZStack {
            Tokens.Color.surfaceCard
            Image(systemName: "photo")
                .font(.system(size: 24.scale, weight: .regular))
                .foregroundStyle(Tokens.Color.textSecondary.opacity(0.5))
        }
        .aspectRatio(1, contentMode: .fill)
    }
}

// MARK: - Toast

private struct CopyToastView: View {
    var body: some View {
        HStack(spacing: 16.scale) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 24.scale, height: 24.scale)
                Image(systemName: "checkmark")
                    .font(Tokens.Font.semibold13)
                    .foregroundStyle(Color(hex: "#141414"))
            }

            Text("Source link copied to clipboard")
                .font(Tokens.Font.interTight16)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16.scale)
        .padding(.vertical, 16.scale)
        .background(
            Capsule(style: .continuous)
                .fill(Color(hex: "#08D54C"))
        )
        .shadow(color: Color.black.opacity(0.12), radius: 10.scale, y: 4.scale)
    }
}

// MARK: - Web sheet контейнер с хедером

private struct HistoryResultWebSheet: View {
    let url: URL
    let onClose: () -> Void

    @State private var isLoading: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
                .background(Tokens.Color.borderNeutral.opacity(0.4))

            ZStack {
                HistoryResultWebView(url: url, isLoading: $isLoading)
                    .id(url)
                    .edgesIgnoringSafeArea(.bottom)

                if isLoading {
                    ZStack {
                        Tokens.Color.backgroundMain
                            .opacity(0.3)
                            .ignoresSafeArea()
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(1.2)
                    }
                }
            }
        }
        .background(Tokens.Color.backgroundMain)
    }

    private var header: some View {
        HStack(spacing: 12.scale) {
            Button(action: onClose) {
                Text("Close")
                    .font(Tokens.Font.bodyMedium16)
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
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.08), radius: 6.scale, y: 2.scale)
    }
}

// MARK: - WKWebView для History

private struct HistoryResultWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: HistoryResultWebView

        init(parent: HistoryResultWebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            print("🌍 [HistoryWebView] didStartProvisionalNavigation: \(webView.url?.absoluteString ?? "nil")")
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            print("✅ [HistoryWebView] didFinish: \(webView.url?.absoluteString ?? "nil")")
        }

        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            parent.isLoading = false
            print("❌ [HistoryWebView] didFailProvisionalNavigation: \(error.localizedDescription)")
        }

        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!,
                     withError error: Error) {
            parent.isLoading = false
            print("❌ [HistoryWebView] didFail: \(error.localizedDescription)")
        }

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            print("⚠️ [HistoryWebView] webViewWebContentProcessDidTerminate, reloading…")
            parent.isLoading = true
            webView.reload()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        let web = WKWebView(frame: .zero, configuration: config)

        web.navigationDelegate = context.coordinator
        web.scrollView.bounces = true
        web.allowsBackForwardNavigationGestures = true

        web.isOpaque = false
        web.backgroundColor = .systemBackground

        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: 30
        )
        web.load(request)

        return web
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
}
