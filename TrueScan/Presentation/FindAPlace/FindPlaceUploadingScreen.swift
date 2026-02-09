// Presentation/FindAPlace/FindAPlaceViewModel/FindPlaceUploadingScreen.swift
// TrueScan
//


import SwiftUI
import Swinject
import UIKit

struct FindPlaceUploadingScreen: View {
    @ObservedObject var vm: FindPlaceViewModel

    let image: UIImage?
    let fileName: String?
    let conversationText: String?
    let apphudId: String
    let onFinished: (String) -> Void
    let onCancelToPreview: () -> Void

    @Environment(\.resolver) private var resolver

    @State private var showPaywall: Bool = false
    @State private var isPremiumUser: Bool = true

    @State private var minDelayPassed: Bool = false
    @State private var analysisCompleted: Bool = false
    @State private var didFinishFlow: Bool = false

    @State private var hasStartedAnalysis: Bool = false
    @State private var delayTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 0) {
            CheaterHeader(
                title: "Place analysis",
                onBack: { handleCancelToPreview() }
            )

            Spacer(minLength: 0)

            VStack(spacing: 30.scale) {
                if let img = image {
                    CheaterImageCard(image: img)
                        .frame(maxWidth: 343.scale)
                        .frame(maxHeight: 460.scale)
                        .padding(.horizontal, 8.scale)
                }

                ThreeDotsLoader()
            }
            .offset(y: -40.scale)

            Spacer(minLength: 0)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .edgeSwipeToPop(isEnabled: true) { handleCancelToPreview() }

        
        .fullScreenCover(isPresented: $showPaywall, onDismiss: {
            handlePaywallDismiss()
        }) {
            let payVM = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: payVM)
                .ignoresSafeArea()
        }

        .onAppear { setupFlow() }
        .onDisappear { cancelTasks() }

        
        .onChange(of: vm.state) { _, newState in
            guard !didFinishFlow else { return }

            switch newState {
            case .result(let text):
                analysisCompleted = true
                completeIfReady(resultText: text)

            case .error:
                didFinishFlow = true
                cancelTasks()

            default:
                break
            }
        }
    }
}

// MARK: - Flow helpers
private extension FindPlaceUploadingScreen {

    func setupFlow() {
        let isPremium = resolver.resolve(PremiumStore.self)?.isPremium ?? false
        isPremiumUser = isPremium

        cancelTasks()
        didFinishFlow = false
        minDelayPassed = false
        analysisCompleted = false

        let totalDuration: TimeInterval = isPremium ? 3.0 : 7.0

        delayTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(totalDuration))
            if Task.isCancelled { return }

            minDelayPassed = true

            if isPremium {
            } else {
                showPaywall = true
            }
        }

        if isPremium {
            startAnalysisIfNeeded()
        }
    }

    func startAnalysisIfNeeded() {
        guard !hasStartedAnalysis else { return }
        hasStartedAnalysis = true

        vm.analyseCurrent(
            conversation: conversationText,
            apphudId: apphudId
        )
    }

    func handlePaywallDismiss() {
        let isPremiumNow = resolver.resolve(PremiumStore.self)?.isPremium ?? false
        isPremiumUser = isPremiumNow

        if isPremiumNow {
            startAnalysisIfNeeded()
        } else {
            didFinishFlow = true
            cancelTasks()
            handleCancelToPreview()
        }
    }

    func completeIfReady(resultText: String) {
        guard !didFinishFlow else { return }
        guard minDelayPassed else { return }
        guard analysisCompleted else { return }

        didFinishFlow = true
        cancelTasks()
        onFinished(resultText)
    }

    func handleCancelToPreview() {
        didFinishFlow = true
        cancelTasks()
        vm.cancelCurrentAnalysis()
        onCancelToPreview()
    }

    func cancelTasks() {
        delayTask?.cancel()
        delayTask = nil
    }
}
