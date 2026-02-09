//
//  FaceSearchLoadingView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI
import Swinject

struct FaceSearchLoadingView: View {
    enum Mode { case name, face }

    let mode: Mode
    let previewImage: UIImage?

    let imageJPEGData: Data?

    @ObservedObject var vm: SearchViewModel
    let onFinished: () -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.resolver) private var resolver

    @State private var showErrorAlert = false
    @State private var errorMessage: String?

    // Paywall
    @State private var showPaywall: Bool = false

    // Подписка
    @State private var isPremiumUser: Bool = true

    
    @State private var matchesCount: Int = 1

    
    @State private var minDelayPassed: Bool = false
    @State private var searchCompleted: Bool = false
    @State private var didFinishFlow: Bool = false

    
    @State private var hasStartedSearch: Bool = false

    
    @State private var fakeCounterTask: Task<Void, Never>?
    @State private var delayTask: Task<Void, Never>?

    

    init(
        mode: Mode,
        previewImage: UIImage?,
        imageJPEGData: Data? = nil,
        vm: SearchViewModel,
        onFinished: @escaping () -> Void
    ) {
        self.mode = mode
        self.previewImage = previewImage
        self.imageJPEGData = imageJPEGData
        self.vm = vm
        self.onFinished = onFinished
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    BackButton(size: 44.scale) { dismiss() }
                        .disabled(vm.isLoading)
                        .opacity(vm.isLoading ? 0.5 : 1)
                    Spacer()
                    Text("Search by photo")
                        .font(Tokens.Font.bodyMedium18)
                        .foregroundStyle(Tokens.Color.textPrimary)
                    Spacer()
                    Color.clear.frame(width: 44.scale, height: 44.scale)
                }
                .padding(.horizontal, 16.scale)
                .padding(.top, 0.scale)

                Spacer(minLength: 0)

                if mode == .face, let ui = previewImage {
                    VStack(spacing: 16.scale) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8.scale, style: .continuous))
                            .shadow(
                                color: Tokens.Color.blue,
                                radius: 0,
                                x: 2.scale,
                                y: 2.scale
                            )
                            .frame(maxWidth: .infinity)
                            .padding(16.scale)

                        Text("Photo analysis")
                            .font(Tokens.Font.medium20)
                            .foregroundStyle(Tokens.Color.textPrimary)

                        VStack(spacing: 12.scale) {
                            // Matches found in databases 24
                            HStack(spacing: 4.scale) {
                                Text("Matches found in databases")
                                    .font(Tokens.Font.captionRegular)
                                    .foregroundStyle(Tokens.Color.textSecondary)

                                Text("\(matchesCount)")
                                    .font(Tokens.Font.captionRegular)
                                    .foregroundStyle(Tokens.Color.accent)
                            }

                            ThreeDotsLoader()
                        }
                        .padding(.top, 8.scale)
                        .padding(.bottom, 52.scale)
                    }
                } else {
                    VStack(spacing: 16.scale) {
                        ThreeDotsLoader()
                        Text("Searching...")
                            .font(Tokens.Font.body)
                            .foregroundStyle(Tokens.Color.textPrimary)
                    }
                }

                Spacer(minLength: 0)
            }
        }
        .navigationBarBackButtonHidden(true)
        
        .toolbar(.hidden, for: .tabBar)

        
        .fullScreenCover(isPresented: $showPaywall, onDismiss: {
            handlePaywallDismiss()
        }) {
            let payVM = resolver.resolve(PaywallViewModel.self)!
            PaywallView(vm: payVM)
                .ignoresSafeArea()
        }

        // MARK: - Жизненный цикл
        .onAppear {
            setupFlow()
        }
        .onDisappear {
            cancelTasks()
        }

        // MARK: - Реакция на завершение загрузки
        .onChange(of: vm.isLoading) { _, isNowLoading in
            guard !didFinishFlow else { return }

            if isNowLoading == false {
                if let msg = vm.errorText, !msg.isEmpty {
                    errorMessage = msg
                    showErrorAlert = true
                    cancelTasks()
                } else {
                    // Успешный ответ сервера
                    searchCompleted = true
                    completeIfReady()
                }
            }
        }
        .onChange(of: vm.errorText) { _, msg in
            guard let msg, !msg.isEmpty else { return }
            errorMessage = msg
            showErrorAlert = true
            cancelTasks()
        }
        .alert("Search failed", isPresented: $showErrorAlert) {
            Button("OK") {
                vm.resetResults()
                dismiss()
            }
        } message: {
            Text(errorMessage ?? "Internal Server Error")
        }
    }
}

// MARK: - Вспомогательные методы
private extension FaceSearchLoadingView {
    func setupFlow() {
        // Определяем, премиум ли пользователь на старте
        let isPremium = resolver.resolve(PremiumStore.self)?.isPremium ?? false
        isPremiumUser = isPremium

        cancelTasks()
        didFinishFlow = false
        minDelayPassed = false
        searchCompleted = false
        hasStartedSearch = false

        let totalDuration: TimeInterval = isPremium ? 3.0 : 7.0

        
        if mode == .face {
            fakeCounterTask = Task { @MainActor in
                let steps = [1, 3, 8, 11]
                matchesCount = steps.first ?? 1
                if steps.count > 1 {
                    let stepDuration = totalDuration / Double(steps.count - 1)
                    for value in steps.dropFirst() {
                        try? await Task.sleep(for: .seconds(stepDuration))
                        if Task.isCancelled { return }
                        matchesCount = value
                    }
                }
            }
        }

        
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
            startSearchIfNeeded()
        }
    }

    
    
    func startSearchIfNeeded() {
        guard !hasStartedSearch else { return }
        guard mode == .face, let jpeg = imageJPEGData else { return }

        hasStartedSearch = true

        vm.resetResults()
        vm.runImageSearch(jpegData: jpeg)
    }

    
    func completeIfReady() {
        guard isPremiumUser else { return }
        guard !didFinishFlow else { return }
        guard minDelayPassed && searchCompleted else { return }

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

            
            startSearchIfNeeded()

            
            
            completeIfReady()
        } else {
            
            didFinishFlow = true
            cancelTasks()
            dismiss()
        }
    }

    func cancelTasks() {
        fakeCounterTask?.cancel()
        delayTask?.cancel()
        fakeCounterTask = nil
        delayTask = nil
    }
}


 
