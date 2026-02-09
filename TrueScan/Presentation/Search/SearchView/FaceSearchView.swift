//  FaceSearchView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/01/25.
//

import SwiftUI
import PhotosUI
import Swinject
import UIKit

struct FaceSearchView: View {

    enum SearchTarget {
        case woman
        case man

        var title: String {
            switch self {
            case .woman: return "Woman"
            case .man:   return "Man"
            }
        }
    }

    @ObservedObject var vm: SearchViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.resolver) private var resolver
    
    @Environment(\.selectedFaceImage) private var initialImage: UIImage?

    @State private var item: PhotosPickerItem?
    @State private var image: UIImage?

    @State private var showPhotoPicker: Bool = false
    @State private var didSelectPhoto: Bool = false

    @State private var rotationAngle: Angle = .zero
    @State private var userZoom: CGFloat = 1.0

    @State private var showLoading: Bool = false
    @State private var loadingPreview: UIImage? = nil

    
    @State private var loadingJPEG: Data? = nil

    let onFinished: () -> Void

    @State private var isCropping: Bool = false
    @State private var cropRect: CGRect = .zero
    @State private var previewSize: CGSize = .zero

    private let minCropSize: CGFloat = 120
    private let cropInset: CGFloat = 16

    private var minCropSizeScaled: CGFloat { minCropSize.scale }
    private var cropInsetScaled: CGFloat { cropInset.scale }

    @State private var selectedTarget: SearchTarget = .man

    // MARK: - Init

    init(vm: SearchViewModel, onFinished: @escaping () -> Void) {
        self.vm = vm
        self.onFinished = onFinished
    }

    // MARK: - Body

    var body: some View {
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first(where: { $0.isKeyWindow })

        let topInset = window?.safeAreaInsets.top ?? 0

        let baseTopPadding: CGFloat = 20.scale

        let safeTopPadding: CGFloat = {
            switch DeviceLayout.type {
            case .smallStatusBar:
                return 90.scale
            case .notch, .dynamicIsland:
                return max(topInset, 60.scale)
            case .unknown:
                return max(topInset, 20.scale)
            }
        }()

        let imageHeight: CGFloat = {
            switch DeviceLayout.type {
            case .smallStatusBar:
                return 300.scale
            case .notch, .dynamicIsland:
                return 430.scale
            case .unknown:
                return 430.scale
            }
        }()

        return ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderBar(title: "Search by photo") { dismiss() }
                    
                VStack(alignment: .leading, spacing: 12.scale) {
                    Text("Who are you searching for?")
                        .font(Tokens.Font.medium20)
                        .foregroundStyle(Tokens.Color.textPrimary)

                    genderSelector
                }
                .padding(.horizontal, 24.scale)
                .padding(.top,  12.scale)
                .padding(.bottom, 8.scale)

                // MARK: - Preview
                FacePreviewCanvas(
                    image: image,
                    rotationAngle: $rotationAngle,
                    userZoom: $userZoom,
                    isCropping: $isCropping,
                    cropRect: $cropRect,
                    previewSize: $previewSize,
                    minCropSize: minCropSizeScaled,
                    cropInset: cropInsetScaled,
                    imageVisibleRect: imageVisibleRect(in:rotatedImageSize:),
                    rotatedBaseSize: rotatedBaseSize,
                    initialCropRect: initialCropRect(for:image:rotation:zoom:)
                )
                .frame(height: imageHeight)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 24.scale)
                .padding(.vertical, 8.scale)

                Spacer(minLength: 0)
            }
            .padding(.top, safeTopPadding.scale + (DeviceLayout.isSmallStatusBarPhone ? 0.scale : 24.scale))
        }
        .navigationBarBackButtonHidden(true)
        .buttonStyle(OpacityTapButtonStyle())
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 32.scale) {

                // три контрол-кнопки
                HStack(spacing: 24.scale) {
                    ControlButton(asset: "rotateLeft") {
                        withAnimation { rotationAngle -= .degrees(90) }
                    }

                    ControlButton(asset: "rotateRight") {
                        withAnimation { rotationAngle += .degrees(90) }
                    }

                    ControlButton(asset: "resize") {
                        if isCropping == false {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                isCropping = true
                            }
                            if let img = image {
                                var t = Transaction(); t.disablesAnimations = true
                                withTransaction(t) {
                                    cropRect = initialCropRect(
                                        for: previewSize,
                                        image: img,
                                        rotation: rotationAngle,
                                        zoom: userZoom
                                    )
                                }
                            }
                        } else {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                isCropping = false
                            }
                        }
                    }
                }

                
                FaceStartSearchButton(
                    isEnabled: image != nil,
                    action: {
                        guard let img = image else { return }
                        runSearchPipeline(with: img)
                    }
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 24.scale)
            .padding(.top, baseTopPadding)
            .padding(.bottom, 110.scale)
            //.background(Tokens.Color.surfaceCard)
        }

        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $item,
            matching: .images
        )
        .onChange(of: item) { _, newValue in
            didSelectPhoto = newValue != nil

            Task { @MainActor in
                guard let data = try? await newValue?.loadTransferable(type: Data.self),
                      let img = UIImage(data: data) else { return }
                image = img
                rotationAngle = .zero
                userZoom = 1.0
                isCropping = false
            }
        }
        .onChange(of: showPhotoPicker) { wasPresented, isPresented in
            if wasPresented && !isPresented && didSelectPhoto == false && image == nil {
                
                dismiss()
            }
        }
        
        .navigationDestination(isPresented: $showLoading) {
            FaceSearchLoadingView(
                mode: .face,
                previewImage: loadingPreview,
                imageJPEGData: loadingJPEG,
                vm: vm,
                onFinished: {
                    onFinished()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        showLoading = false
                    }
                }
            )
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .transaction { t in t.animation = nil }
            .transition(.identity)
        }

        .onAppear {
            if image == nil, let initial = initialImage {
                
                image = initial
                rotationAngle = .zero
                userZoom = 1.0
                isCropping = false
            } else if image == nil && initialImage == nil {
                
                showPhotoPicker = true
            }
        }
    }
}

private extension FaceSearchView {

    var genderSelector: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 12.scale, style: .continuous)
//                .fill(Color.white)
//                .shadow(color: Color.black.opacity(0.06), radius: 6.scale)
//                .shadow(
//                    color: Color.black,
//                    radius: 0,
//                    x: 2,
//                    y: 2
//                )

            HStack(spacing: 8.scale) {
                genderSegment(.woman)
                genderSegment(.man)
            }
            .padding(0.scale)
        }
        .frame(width: 343.scale, height: 43.scale)
    }

    func genderSegment(_ target: SearchTarget) -> some View {
        let isSelected = (target == selectedTarget)

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                selectedTarget = target
            }
        } label: {
            Text(target.title)
                .font(Tokens.Font.bodySemibold16)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(isSelected ? Color.white : Tokens.Color.textPrimary)
                .background(
                    RoundedRectangle(cornerRadius: 12.scale, style: .continuous)
                        .fill(isSelected ? Tokens.Color.accent : Color.white)
                        .shadow(
                            color: Color.black,
                            radius: 0,
                            x: 2.scale,
                            y: 2.scale
                        )
                )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 12.scale, style: .continuous))
    }
}

private struct FaceStartSearchButton: View {
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button {
            if isEnabled { action() }
        } label: {
            ZStack {
                RoundedRectangle(
                    cornerRadius: Tokens.Radius.medium,
                    style: .continuous
                )
                .fill(isEnabled ? Tokens.Color.accent : Color(hex: "#DC97AB"))
                .shadow(
                    color: Color.black,
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )

                HStack(spacing: 8.scale) {
                    Text("Start search")
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
        .frame(maxWidth: .infinity, alignment: .center)
        .disabled(!isEnabled)
    }
}


private extension FaceSearchView {
    func runSearchPipeline(with img: UIImage) {
        let finalImage: UIImage = ImageCropper.editedImage(
            source: img,
            imageViewSize: previewSize,
            rotation: rotationAngle,
            userZoom: userZoom,
            imageOffset: .zero,
            cropRectInView: cropRect,
            isCropping: isCropping
        ) ?? img

        
        loadingPreview = finalImage
        loadingJPEG = finalImage.jpegData(compressionQuality: 0.85)

        Analytics.shared.track("search_face_total")

        switch selectedTarget {
        case .woman:
            Analytics.shared.track("search_face_woman")
        case .man:
            Analytics.shared.track("search_face_man")
        }

      
        showLoading = true
    }
}

// MARK: - Geometry helpers

private extension FaceSearchView {
    func imageVisibleRect(in container: CGSize, rotatedImageSize: CGSize) -> CGRect {
        let s = min(container.width / rotatedImageSize.width,
                    container.height / rotatedImageSize.height)
        let drawSize = CGSize(width: rotatedImageSize.width * s * userZoom,
                              height: rotatedImageSize.height * s * userZoom)
        let origin = CGPoint(x: (container.width - drawSize.width) / 2.0,
                             y: (container.height - drawSize.height) / 2.0)
        let imgRect = CGRect(origin: origin, size: drawSize)
        return imgRect.intersection(CGRect(origin: .zero, size: container)).integral
    }

    func rotatedBaseSize() -> CGSize {
        guard let img = image else { return .zero }
        let deg = (abs(Int(rotationAngle.degrees)) % 360 + 360) % 360
        let swap = (deg == 90 || deg == 270)
        return CGSize(width: swap ? img.size.height : img.size.width,
                      height: swap ? img.size.width  : img.size.height)
    }

    func initialCropRect(for container: CGSize, image: UIImage, rotation: Angle, zoom: CGFloat) -> CGRect {
        let visible = imageVisibleRect(in: container, rotatedImageSize: rotatedBaseSize())
        var r = visible.insetBy(dx: cropInsetScaled, dy: cropInsetScaled)
        if r.width < minCropSizeScaled || r.height < minCropSizeScaled {
            r = visible.fitting(minSide: minCropSizeScaled)
        }
        return r.integral
    }
}
