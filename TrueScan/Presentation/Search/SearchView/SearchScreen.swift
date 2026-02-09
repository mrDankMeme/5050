//
//  SearchScreen.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//

import SwiftUI
import Swinject
import PhotosUI
import UniformTypeIdentifiers
import UIKit

private struct SelectedFaceImageKey: EnvironmentKey {
    static let defaultValue: UIImage? = nil
}

extension EnvironmentValues {
    var selectedFaceImage: UIImage? {
        get { self[SelectedFaceImageKey.self] }
        set { self[SelectedFaceImageKey.self] = newValue }
    }
}

struct SearchScreen: View {
    
    enum Route: Hashable {
        case face
        case results
    }

    @State private var path: [Route] = []

    @StateObject private var vm: SearchViewModel

    
    private let onClose: () -> Void

    @State private var showSourceSheet = false

    
    @State private var photoItem: PhotosPickerItem?
    @State private var showPhotoPicker = false

    
    @State private var showFilePicker = false

    
    @State private var selectedImage: UIImage? = nil

    init(vm: SearchViewModel, onClose: @escaping () -> Void = {}) {
        _vm = StateObject(wrappedValue: vm)
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack(path: $path) {

            
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = windowScene?.windows.first(where: { $0.isKeyWindow })
            let safeBottomInset = window?.safeAreaInsets.bottom ?? 0

            VStack(spacing: 24.scale) {
                header
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSourceSheet = true
                    }
                } label: {
                    UploadPhotoCardView()
                     
                }
                .buttonStyle(OpacityTapButtonStyle())
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 0)
                startSearchButton
            }
            .padding(.horizontal, Tokens.Spacing.x16)
            .padding(.top, Tokens.Spacing.x8)
            .padding(.bottom, safeBottomInset + 24.scale)
            .background(Tokens.Color.backgroundMain.ignoresSafeArea())
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .face:
                    FaceSearchView(vm: vm, onFinished: { path.append(.results) })
                        .navigationBarBackButtonHidden(true)
                        .edgeSwipeToPop(isEnabled: true) { path.removeLast() }
                        
                        .environment(\.selectedFaceImage, selectedImage)

                case .results:
                    SearchResultsView(vm: vm, path: $path)
                        .navigationBarBackButtonHidden(true)
                        .edgeSwipeToPop(isEnabled: true) { path.removeLast() }
                }
            }
            .photosPicker(
                isPresented: $showPhotoPicker,
                selection: $photoItem,
                matching: .images
            )
            .onChange(of: photoItem) { _, item in
                guard let item else { return }

                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        await MainActor.run {
                            selectedImage = img
                            navigateToFaceIfNeeded()
                        }
                    }
                    await MainActor.run {
                        photoItem = nil
                    }
                }
            }
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
                        if let img = UIImage(data: data) {
                            selectedImage = img
                            navigateToFaceIfNeeded()
                        }
                    } catch {
                        print("Failed to read image file: \(error.localizedDescription)")
                    }

                case .failure(let error):
                    print("File import failed: \(error.localizedDescription)")
                }
            }
            .overlay(alignment: .bottom) {
                if showSourceSheet {
                    SourcePickerOverlay(
                        onFiles: {
                            showSourceSheet = false
                            showFilePicker  = true
                        },
                        onLibrary: {
                            showSourceSheet = false
                            showPhotoPicker = true
                        },
                        onDismiss: {
                            showSourceSheet = false
                        }
                    )
                    .zIndex(1000)
                    .ignoresSafeArea()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: path) { _, newPath in
            let shouldHideTabBar = !newPath.isEmpty
            TabBarTransparencyAnimator.setTransparent(shouldHideTabBar)
        }
        .onAppear {
            TabBarTransparencyAnimator.setTransparent(false)
        }
        .onDisappear {
            TabBarTransparencyAnimator.setTransparent(false)
        }
    }

    private func navigateToFaceIfNeeded() {
        if !path.contains(.face) {
            path.append(.face)
        }
    }
    
    private var header: some View {
        ZStack {
            
            Text("Search by photo")
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

    private var startSearchButton: some View {
        let hasImage = (selectedImage != nil)

        return Button {
            if hasImage {
                navigateToFaceIfNeeded()
            } else {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showSourceSheet = true
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(
                    cornerRadius: Tokens.Radius.medium,
                    style: .continuous
                )
                .fill(hasImage ? Tokens.Color.accent : Color(hex: "#DC97AB"))
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )

                HStack(spacing: 8.scale) {
                    Text("Start search")
                        .font(Tokens.Font.semibold16)
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
        .frame(maxWidth: .infinity, alignment: .center)
    }

}

private struct UploadPhotoCardView: View {
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
                    .font(Tokens.Font.semibold16)
                    .foregroundStyle(Tokens.Color.blue)
            }
        }
        .frame(width: 343.scale, height: 200.scale)
    }
}
