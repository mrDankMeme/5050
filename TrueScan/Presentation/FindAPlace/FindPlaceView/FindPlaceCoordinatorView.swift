// Presentation/FindAPlace/FindPlaceView/FindPlaceCoordinatorView.swift
// TrueScan

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import UIKit
import Swinject

struct FindPlaceCoordinatorView: View {

    // MARK: - Types

    enum Route: Hashable {
        case imagePreview
        case uploading
        case result
    }

    // MARK: - Input

    @ObservedObject var vm: FindPlaceViewModel
    let onClose: () -> Void

    @Environment(\.resolver) private var resolver

    @State private var path: [Route] = []

    @State private var showSourceSheet: Bool = false

    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker: Bool = false

    @State private var showFilePicker: Bool = false

    @State private var lastPreviewImage: UIImage? = nil
    @State private var lastEditedImageForUpload: UIImage? = nil

    @State private var routedResultText: String? = nil
    
    @State private var didSaveResultToHistory: Bool = false

    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            FindPlaceRootContentView(
                onClose: onClose,
                onUploadTap: { openSourceSheet() },
                onBottomTap: { proceedFromRootIfPossible() },
                hasUploadedImage: lastPreviewImage != nil
            )
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .navigationBarBackButtonHidden(true)
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $photoItem,
                matching: .images
            )
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.image],
                allowsMultipleSelection: false,
                onCompletion: handleFileImport(result:)
            )
            .onChange(of: photoItem, handlePhotoItemChange)
            .onChange(of: path) { _, _ in
                showSourceSheet = false
            }

            // Навигация по состояниям VM
            .onChange(of: vm.state) { _, newState in
                switch newState {
                case .result(let text):
                    handleResultAndRoute(text)

                case .error(let message):
                    errorMessage = message
                    showErrorAlert = true

                default:
                    break
                }
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) {
                    path.removeAll()
                    resetLocalState()
                    vm.goBackToUpload()
                }
            } message: {
                Text(errorMessage)
            }
        }
        .overlay(alignment: .bottom) { sourcePickerOverlay }
        .toolbar(showSourceSheet ? .hidden : .visible, for: .tabBar)
        .animation(.easeInOut(duration: 0.25), value: showSourceSheet)
        .onAppear {
            TabBarTransparencyAnimator.setTransparent(false)
            showSourceSheet = false
        }
        .onDisappear {
            TabBarTransparencyAnimator.setTransparent(false)
        }
        .enableInteractivePop()
        .buttonStyle(OpacityTapButtonStyle())
    }

    // MARK: - Navigation destinations

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {

        case .imagePreview:
            FindPlaceImagePreviewScreen(
                image: lastPreviewImage,
                onAnalyse: { finalImage in
                    lastEditedImageForUpload = finalImage
                    vm.showImage(finalImage)
                    push(.uploading)
                },
                onBack: { _ = path.popLast() }
            )

        case .uploading:
            FindPlaceUploadingScreen(
                vm: vm,
                image: lastEditedImageForUpload ?? lastPreviewImage,
                fileName: nil,
                conversationText: nil,
                apphudId: currentApphudId(),
                onFinished: { resultText in
                    
                    handleResultAndRoute(resultText)
                },
                onCancelToPreview: {
                    vm.cancelCurrentAnalysis()

                    if let img = lastPreviewImage {
                        vm.showImage(img)
                    }

                    if path.last == .uploading {
                        _ = path.popLast()
                    }
                }
            )

        case .result:
            FindPlaceResultScreen(
                image: lastEditedImageForUpload ?? lastPreviewImage,
                resultText: routedResultText ?? "Empty result",
                onBack: {
                    path.removeAll()
                    resetLocalState()
                    vm.goBackToUpload()
                },
                onFindOutMore: {
                    path.removeAll()
                    resetLocalState()
                    vm.goBackToUpload()

                    DispatchQueue.main.async {
                        openSourceSheet()
                    }
                }
            )
            .navigationBarBackButtonHidden(true)
            .edgeSwipeToPop(isEnabled: true) {
                path.removeAll()
                resetLocalState()
                vm.goBackToUpload()
            }
        }
    }

    private func push(_ route: Route) {
        if path.last != route { path.append(route) }
    }

    // MARK: - Overlay

    @ViewBuilder
    private var sourcePickerOverlay: some View {
        if showSourceSheet {
            SourcePickerOverlay(
                onFiles: {
                    showSourceSheet = false
                    showFilePicker = true
                    TabBarTransparencyAnimator.setTransparent(false)
                },
                onLibrary: {
                    showSourceSheet = false
                    showPhotoPicker = true
                    TabBarTransparencyAnimator.setTransparent(false)
                },
                onDismiss: {
                    showSourceSheet = false
                    TabBarTransparencyAnimator.setTransparent(false)
                }
            )
            .zIndex(1000)
            .ignoresSafeArea()
        }
    }

    private func openSourceSheet() {
        withAnimation(.easeInOut(duration: 0.25)) {
            showSourceSheet = true
        }
    }

    // MARK: - Root proceed

    private func proceedFromRootIfPossible() {
        guard let img = lastPreviewImage else {
            return
        }

        vm.showImage(img)
        push(.imagePreview)
    }

    // MARK: - Result handling (History + Route)

    private func handleResultAndRoute(_ resultText: String) {
        
        saveLocationResultToHistoryIfNeeded(resultText: resultText)

        
        routedResultText = resultText
        push(.result)
    }

    private func saveLocationResultToHistoryIfNeeded(resultText: String) {
        guard didSaveResultToHistory == false else { return }
        didSaveResultToHistory = true

        guard let store = resolver.resolve(LocationHistoryStore.self) else {
            
            return
        }

        let thumbImage = (lastEditedImageForUpload ?? lastPreviewImage)
        let thumbData = thumbImage?.jpegData(compressionQuality: 0.9)

        let item = LocationHistoryItem(
            title: resultText,
            thumbnailJPEG: thumbData
        )

        store.add(item)
    }

    // MARK: - Pickers handlers

    private func handleFileImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            let secured = url.startAccessingSecurityScopedResource()
            defer { if secured { url.stopAccessingSecurityScopedResource() } }

            do {
                let data = try Data(contentsOf: url)

                guard let image = UIImage(data: data) else {
                    vm.presentError("Selected file is not a valid image.")
                    return
                }

                lastPreviewImage = image
                lastEditedImageForUpload = nil
                didSaveResultToHistory = false

            } catch {
                vm.presentError("FindPlace: Failed to read file: \(error.localizedDescription)")
            }

        case .failure(let error):
            vm.presentError("FindPlace: File import failed: \(error.localizedDescription)")
        }
    }

    private func handlePhotoItemChange(_ oldValue: PhotosPickerItem?, _ newValue: PhotosPickerItem?) {
        guard let item = newValue else { return }

        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {

                    await MainActor.run {
                        lastPreviewImage = img
                        lastEditedImageForUpload = nil
                        didSaveResultToHistory = false
                    }
                } else {
                    await MainActor.run {
                        vm.presentError("Failed to load selected image.")
                    }
                }
            } catch {
                await MainActor.run {
                    vm.presentError("Failed to load selected image: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Helpers

    private func resetLocalState() {
        lastPreviewImage = nil
        lastEditedImageForUpload = nil
        routedResultText = nil
        photoItem = nil
        showPhotoPicker = false
        showFilePicker = false
        showSourceSheet = false
        didSaveResultToHistory = false
    }

    private func currentApphudId() -> String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
}
