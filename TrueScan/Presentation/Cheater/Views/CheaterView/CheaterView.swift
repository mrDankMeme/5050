// Presentation/Cheater/CheaterView.swift
// CheaterBuster

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Swinject

struct CheaterView: View {
    @ObservedObject var vm: CheaterViewModel
    @EnvironmentObject private var router: AppRouter
    @Environment(\.resolver) private var resolver

    
    
    private let onClose: () -> Void

    
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false

    
    @State private var showFilePicker = false

    
    @State private var conversationText: String = ""

    
    @State private var showSavedAlert = false

    
    @State private var showSourceSheet = false

    
    @State private var lastPreviewImage: UIImage? = nil
    @State private var lastFileName: String? = nil
    @State private var lastFileData: Data? = nil

   
    @State private var lastEditedImageForUpload: UIImage? = nil

    
    @State private var showErrorAlert = false
    @State private var errorMessage: String = ""


    @State private var hasEverRunAnalysis: Bool = false

    // Навигация
    private enum CheaterRoute: Hashable {
        case imagePreview
        case filePreview
        case uploading
        case result
    }

    @State private var path: [CheaterRoute] = []
    @State private var routedResult: TaskResult? = nil

    // MARK: - Init

    init(vm: CheaterViewModel, onClose: @escaping () -> Void = {}) {
        self.vm = vm
        self.onClose = onClose
    }

    // MARK: - Helpers

    private var isFileContext: Bool {
        lastPreviewImage == nil && lastFileName != nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $path) {
            
            VStack(spacing: 24.scale) {
                header

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSourceSheet = true
                    }
                } label: {
                    CheaterUploadPhotoCardView()
                }
                .buttonStyle(OpacityTapButtonStyle())
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 0)

                checkMessagesButton
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x8)
            .padding(.bottom, 24.scale)
            .ignoresSafeArea(edges: .bottom)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())

       
            .navigationDestination(for: CheaterRoute.self) { route in
                switch route {
                case .imagePreview:
                    CheaterImagePreviewScreen(
                        image: lastPreviewImage,
                        resolver: resolver,
                        onAnalyse: { [weak vm] finalImage in
                            guard let vm else { return }

                            lastEditedImageForUpload = finalImage

                            vm.showImage(finalImage)

                            
                            
                            hasEverRunAnalysis = true

                            
                            if path.last != .uploading {
                                path.append(.uploading)
                            }
                        },
                        onBack: { _ = path.popLast() }
                    )

                case .filePreview:
                    CheaterFilePreviewScreen(
                        name: lastFileName,
                        data: lastFileData,
                        resolver: resolver,
                        onAnalyse: { [weak vm] in
                            guard let vm else { return }

                            
                            hasEverRunAnalysis = true

                            if path.last != .uploading {
                                path.append(.uploading)
                            }
                        },
                        onBack: { _ = path.popLast() }
                    )

                case .uploading:
                    CheaterUploadingScreen(
                        vm: vm,
                        
                        
                        image: lastEditedImageForUpload ?? lastPreviewImage,
                        fileName: lastFileName,
                        conversationText: conversationText,
                        apphudId: currentApphudId(),
                        onFinished: {
                            if path.last != .result {
                                path.append(.result)
                            }
                        },
                        onCancelToPreview: {
                           
                            if let img = lastPreviewImage {
                                vm.showImage(img)
                            } else if let name = lastFileName,
                                      let data = lastFileData {
                                vm.showFile(name: name, data: data)
                            }

                            if path.last == .uploading {
                                _ = path.popLast()
                            }
                        }
                    )

                case .result:
                    if let r = routedResult {
                        CheaterResultView(
                            result: r,
                            onBack: {
                                path.removeAll()
                                vm.goBackToIdle()
                                lastEditedImageForUpload = nil
                            },
                            onSelectMessage: {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    showSourceSheet = true
                                }
                            },
                            analysisTitle: isFileContext ? "Files analysis" : "Image analysis"
                        )
                        .navigationBarBackButtonHidden(true)
                        .edgeSwipeToPop(isEnabled: true) {
                            path.removeAll()
                            vm.goBackToIdle()
                            lastEditedImageForUpload = nil
                        }
                    } else {
                        VStack {
                            Text("No result")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .navigationBarBackButtonHidden(true)
                        .edgeSwipeToPop(isEnabled: true) {
                            path.removeLast()
                        }
                    }
                }
            }

          

            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $photoItem,
                matching: .images
            )
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [.image],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    let secured = url.startAccessingSecurityScopedResource()
                    defer { if secured { url.stopAccessingSecurityScopedResource() } }

                    do {
                        let data = try Data(contentsOf: url)
                        vm.showFile(name: url.lastPathComponent, data: data)
                        lastPreviewImage = nil
                        lastEditedImageForUpload = nil
                        lastFileName = url.lastPathComponent
                        lastFileData = data
                        if path.last != .filePreview {
                            path.append(.filePreview)
                        }
                    } catch {
                        vm.presentError("Failed to read file: \(error.localizedDescription)")
                    }

                case .failure(let error):
                    vm.presentError(error.localizedDescription)
                }
            }

            // Фото -> UIImage
            .onChange(of: photoItem) { _, item in
                guard let item else { return }

                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img  = UIImage(data: data) {
                        await MainActor.run {
                            vm.showImage(img)
                            lastPreviewImage = img
                            lastEditedImageForUpload = nil
                            lastFileName = nil
                            lastFileData = nil
                            path.append(.imagePreview)
                        }
                    } else {
                        await MainActor.run {
                            vm.presentError("Failed to load photo")
                        }
                    }
                    await MainActor.run { photoItem = nil }
                }
            }

            
            .alert("Saved to History", isPresented: $showSavedAlert) {
                Button("Open History") { router.openHistoryCheater() }
                Button("OK", role: .cancel) { }
            }

            
            .onChange(of: vm.state) { _, newState in
                switch newState {
                case .previewFile(let name, let data):
                    lastPreviewImage = nil
                    lastEditedImageForUpload = nil
                    lastFileName = name
                    lastFileData = data
                    if path.last != .filePreview {
                        path.append(.filePreview)
                    }

                case .uploading:
                    
                    
                    if path.last != .uploading {
                        path.append(.uploading)
                    }

                case .result(let r):
                    routedResult = r
                    Task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        await MainActor.run {
                            vm.saveToHistory()
                        }
                    }

                case .error(let message):
                    errorMessage = CheaterViewHelpers.prettyErrorMessage(message)
                    showErrorAlert = true

                default:
                    break
                }
            }

            
            .onChange(of: path) { _, newPath in
                if newPath.isEmpty, vm.state != .idle {
                    vm.goBackToIdle()
                    lastEditedImageForUpload = nil
                }
            }
        }

        
        .alert("Analysis failed", isPresented: $showErrorAlert) {
            Button("OK") {
                path.removeAll()
                vm.goBackToIdle()
                lastEditedImageForUpload = nil
            }
        } message: {
            Text(errorMessage)
        }

        
        .overlay(alignment: .bottom) {
            if showSourceSheet {
                SourcePickerOverlay(
                    onFiles: {
                        showSourceSheet = false
                        showFilePicker  = true
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

        
        .toolbar(showSourceSheet ? .hidden : .visible, for: .tabBar)
        .animation(.easeInOut(duration: 0.25), value: showSourceSheet)

        .onAppear {
            TabBarTransparencyAnimator.setTransparent(false)
            showSourceSheet = false
        }
        .onDisappear {
            TabBarTransparencyAnimator.setTransparent(false)
        }
        .onChange(of: path) { _, _ in
            showSourceSheet = false
        }
        .enableInteractivePop()
        .buttonStyle(OpacityTapButtonStyle())
    }

    // MARK: - Header ("Check messages")

    private var header: some View {
        ZStack {
            
            Text("Check messages")
                .font(Tokens.Font.medium18)
                .foregroundStyle(Tokens.Color.textPrimary)

            
            HStack {
                Button {
                    onClose()
                } label: {
                    Image("backButton")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 24.scale, height: 24.scale)
                }
                .foregroundStyle(Tokens.Color.textPrimary)

                Spacer()
            }
        }
        .padding(.top, 4.scale)
    }

    // MARK: - Нижняя кнопка "Check messages"

    private var checkMessagesButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                showSourceSheet = true
            }
        } label: {
            ZStack {
                RoundedRectangle(
                    cornerRadius: Tokens.Radius.medium,
                    style: .continuous
                )
                .fill(hasEverRunAnalysis ? Tokens.Color.accent : Color(hex: "#DC97AB"))
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )

                HStack(spacing: 8.scale) {
                    Text("Check messages")
                        .font(Tokens.Font.bodySemibold16)
                        .tracking(-0.16)

                    Spacer()

                    Image("nextArrow")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 20.scale, height: 20.scale)
                }
                .foregroundColor(.white)
                .padding(.leading, 20.scale)
                .padding(.trailing, 24.scale)
            }
            .frame(width: 343.scale, height: 51.scale)
        }
        .buttonStyle(OpacityTapButtonStyle())
        .disabled(!hasEverRunAnalysis)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, 24.scale)
    }


    // MARK: - Apphud identity (stable per app installation)

    private func currentApphudId() -> String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
}

// MARK: - Карточка Upload photo (Cheater)

private struct CheaterUploadPhotoCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24.scale, style: .continuous)
                .fill(Tokens.Color.blue)
                .offset(x: 2.scale, y: 2.scale)

            RoundedRectangle(cornerRadius: 24.scale, style: .continuous)
                .fill(Color(hex: "#DDE4EF"))

            VStack(spacing: 12.scale) {
                Image("search.imageIcom")
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .frame(width: 32.scale, height: 32.scale)
                    .foregroundStyle(Tokens.Color.blue)

                Text("Upload a photo")
                    .font(Tokens.Font.bodySemibold16)
                    .foregroundStyle(Tokens.Color.blue)
            }
        }
        .frame(width: 343.scale, height: 200.scale)
    }
}
