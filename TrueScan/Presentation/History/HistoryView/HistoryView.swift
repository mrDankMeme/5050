// Presentation/History/HistoryView.swift
// CheaterBuster
//


import SwiftUI
import UIKit
import Swinject

struct HistoryView: View {

    @StateObject private var vm: HistoryViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.resolver) private var resolver

    // MARK: - Path navigation

    enum Route: Hashable { case faceResults; case imageResults; case locationResult }

    @State private var path: [Route] = []
    @State private var showPaywall = false
    @State private var didNavigate = false
    
    private var isResultsScreen: Bool { !path.isEmpty }

    init(vm: HistoryViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Tokens.Color.backgroundMain.ignoresSafeArea()
                content
                    .background(Color.clear)
                    .navigationBarTitleDisplayMode(.inline)
                    .onAppear {
                        didNavigate = false
                        vm.reload()
                        vm.segment = router.historyPreferredSegment
                    }
                    .onChange(of: vm.segment) { _, _ in
                        vm.cancelInFlight()
                        didNavigate = false
                    }
                    .onChange(of: router.historyPreferredSegment) { _, seg in
                        vm.segment = seg
                    }
                    .onChange(of: vm.rerunResults) { _, hits in
                        guard !didNavigate, !hits.isEmpty else { return }
                        didNavigate = true
                        path.append(.faceResults)
                    }
                    .onChange(of: vm.selectedCheater) { _, rec in
                        guard !didNavigate, rec != nil else { return }
                        didNavigate = true
                        path.append(.imageResults)
                    }
                    .onChange(of: vm.selectedLocation) { _, item in
                        guard !didNavigate, item != nil else { return }
                        didNavigate = true
                        path.append(.locationResult)
                    }
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .faceResults:
                            HistoryFaceResultsView(hits: vm.rerunResults)
                                .navigationBarBackButtonHidden(true)
                                .edgeSwipeToPop(isEnabled: true) {
                                    didNavigate = false
                                    path.removeLast()
                                }

                        case .imageResults:
                            if let rec = vm.selectedCheater {
                                CheaterResultView(
                                    record: rec,
                                    onBack: {
                                        didNavigate = false
                                        vm.selectedCheater = nil
                                        path.removeLast()
                                    },
                                    onSelectMessage: {},
                                    // MARK: - Added: hide CTA when opened from History
                                    showSelectMessageButton: false
                                )
                                .navigationBarBackButtonHidden(true)
                                .edgeSwipeToPop(isEnabled: true) {
                                    didNavigate = false
                                    path.removeLast()
                                }
                            }

                        case .locationResult:
                            if let item = vm.selectedLocation {
                                FindPlaceResultScreen(
                                    image: uiImage(from: item.thumbnailJPEG),
                                    resultText: item.title,
                                    onBack: {
                                        didNavigate = false
                                        vm.selectedLocation = nil
                                        path.removeLast()
                                    },
                                    onFindOutMore: {
                                        
                                    },
                                    showFindOutMoreButton: false   
                                )
                                .navigationBarBackButtonHidden(true)
                                .edgeSwipeToPop(isEnabled: true) {
                                    didNavigate = false
                                    vm.selectedLocation = nil
                                    path.removeLast()
                                }
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showPaywall) {
                        let paywallVM = resolver.resolve(PaywallViewModel.self)!
                        PaywallView(vm: paywallVM)
                            .ignoresSafeArea()
                    }

                // Оверлей-лоадер
                if vm.isLoading {
                    ZStack {
                        Tokens.Color.backgroundMain
                            .opacity(0.65)
                            .ignoresSafeArea()

                        VStack(spacing: Tokens.Spacing.x16) {
                            ProgressView()
                                .progressViewStyle(
                                    CircularProgressViewStyle(tint: Tokens.Color.accent)
                                )
                                .scaleEffect(1.4)
                        }
                    }
                }
            }
        }
        .onChange(of: isResultsScreen) { _, isResult in
            TabBarTransparencyAnimator.setTransparent(isResult)
        }
        .onAppear {
            TabBarTransparencyAnimator.setTransparent(false)
        }
        .onDisappear {
            TabBarTransparencyAnimator.setTransparent(false)
        }
        .navigationBarBackButtonHidden(true)
        .buttonStyle(OpacityTapButtonStyle())
        
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 0) {

            
            VStack(alignment: .leading, spacing: 0) {
                Text("History")
                    .font(Tokens.Font.h2)
                    .foregroundStyle(Tokens.Color.textPrimary)
                    .padding(.top, 8.scale)
                    .padding(.horizontal, Tokens.Spacing.x16)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            
            SegmentCapsule(selected: $vm.segment, router: router)
                .padding(.horizontal, Tokens.Spacing.x16)
                .padding(.top, Tokens.Spacing.x12)

            
            Group {
                switch vm.segment {
                case .search:
                    SearchGrid(items: vm.items) { rec in
                        guard rec.kind == .face else { return }
                        let isPremium = (resolver.resolve(PremiumStore.self)?.isPremium ?? false)
                        if isPremium {
                            didNavigate = false
                            vm.onTapSearch(rec)
                        } else {
                            showPaywall = true
                        }
                    }
                    .padding(.top, 6.scale)

                case .cheater:
                    CheaterList(items: vm.cheaterItems) { rec in
                        vm.onTapCheater(rec)
                    }
                    .padding(.top, 8.scale)

                case .location:
                    LocationList(items: vm.locationItems) { item in
                        vm.onTapLocation(item)
                    }
                    .padding(.top, 8.scale)
                }
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Helpers

    private func uiImage(from data: Data?) -> UIImage? {
        guard let data else { return nil }
        return UIImage(data: data)
    }
}
