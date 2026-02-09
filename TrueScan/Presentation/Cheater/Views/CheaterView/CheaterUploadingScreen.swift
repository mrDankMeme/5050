// Presentation/Cheater/CheaterUploadingScreen.swift
// CheaterBuster
//


import SwiftUI
import Swinject

struct CheaterUploadingScreen: View {
    @ObservedObject var vm: CheaterViewModel

    let image: UIImage?
    let fileName: String?
    let conversationText: String
    let apphudId: String
    let onFinished: () -> Void
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
                title: (image == nil && fileName != nil) ? "Files analysis" : "Message analysis",
                onBack: { handleCancelToPreview() }
            )

            Spacer(minLength: 0)

            
            VStack(spacing: 30.scale) {
                if let img = image {
                    CheaterImageCard(image: img)
                        
                        .frame(maxWidth: 343.scale)
                        .frame(maxHeight: 460.scale)
                        .padding(.horizontal, 8.scale)

                } else if let name = fileName {
                    ZStackForFileName(name: name)
                        .frame(maxWidth: 343.scale)
                        .padding(.horizontal, 8.scale)
                }

                ThreeDotsLoader()
            }
            
            .offset(y: -40.scale)

            Spacer(minLength: 0)
        }
        .background(Tokens.Color.backgroundMain.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .edgeSwipeToPop(isEnabled: true) {
            handleCancelToPreview()
        }

        
        .fullScreenCover(isPresented: $showPaywall, onDismiss: { handlePaywallDismiss() }) {
            let payVM = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: payVM)
                .ignoresSafeArea()
        }

        .onAppear { setupFlow() }
        .onDisappear { cancelTasks() }

        
        .onChange(of: vm.state) { _, newState in
            guard !didFinishFlow else { return }

            switch newState {
            case .result:
                analysisCompleted = true
                completeIfReady()

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
private extension CheaterUploadingScreen {
    func setupFlow() {
        let isPremium = resolver.resolve(PremiumStore.self)?.isPremium ?? false
        isPremiumUser = isPremium

        cancelTasks()
        didFinishFlow = false
        minDelayPassed = false
        analysisCompleted = false

        let totalDuration: TimeInterval = isPremium ? 3.0 : 7.0

        // Запускаем таймер фейк-лоадера
        delayTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(totalDuration))
            if Task.isCancelled { return }

            minDelayPassed = true

            if isPremium {
                
                completeIfReady()
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

    func completeIfReady() {
        guard isPremiumUser else { return }
        guard !didFinishFlow else { return }
        guard minDelayPassed && analysisCompleted else { return }

        didFinishFlow = true
        cancelTasks()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onFinished()
        }
    }

    
    func handlePaywallDismiss() {
        let premiumNow = resolver.resolve(PremiumStore.self)?.isPremium ?? false

        if premiumNow {
            
            isPremiumUser = true
            minDelayPassed = true

            
            startAnalysisIfNeeded()
            completeIfReady()
        } else {
            
            didFinishFlow = true
            cancelTasks()
            handleCancelToPreview()
        }
    }

    func handleCancelToPreview() {
        vm.cancelCurrentAnalysis()
        onCancelToPreview()
    }

    func cancelTasks() {
        delayTask?.cancel()
        delayTask = nil
    }
}
