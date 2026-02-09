// Presentation/Cheater/CheaterImagePreviewScreen.swift
// CheaterBuster
//

import SwiftUI
import Swinject

struct CheaterImagePreviewScreen: View {
    let image: UIImage?
    let resolver: Resolver

    
    
    let onAnalyse: (UIImage) -> Void
    let onBack: () -> Void

    // MARK: - Rotation / zoom / crop state

    @State private var rotationAngle: Angle = .zero
    @State private var userZoom: CGFloat = 1.0

    @State private var isCropping: Bool = false
    @State private var cropRect: CGRect = .zero
    @State private var previewSize: CGSize = .zero

    private let minCropSize: CGFloat = 120
    private let cropInset: CGFloat = 16

    private var minCropSizeScaled: CGFloat { minCropSize.scale }
    private var cropInsetScaled: CGFloat { cropInset.scale }

    var body: some View {
        ZStack {
            Tokens.Color.backgroundMain.ignoresSafeArea()

            VStack(spacing: 0) {
                CheaterHeader(title: "Message analysis", onBack: onBack)

                VStack(spacing: 16.scale) {
                    Spacer(minLength: 0)

                    if let img = image {
                        
                        FacePreviewCanvas(
                            image: img,
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
                        .frame(height: DeviceLayout.isSmallStatusBarPhone ? 350.scale : 430.scale)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 24.scale)
                        .padding(.vertical, 8.scale)
                    } else {
                        VStack {
                            Text("No image")
                                .foregroundColor(.red)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 24.scale)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .edgeSwipeToPop(isEnabled: true) { onBack() }

        
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if image != nil {
                VStack(spacing: 16.scale) {
                    // 3 круглые кнопки
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
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24.scale)
                    .padding(.bottom, 16.scale)

                    
                    Button {
                        guard let img = image else { return }

                        let finalImage: UIImage = ImageCropper.editedImage(
                            source: img,
                            imageViewSize: previewSize,
                            rotation: rotationAngle,
                            userZoom: userZoom,
                            imageOffset: .zero,
                            cropRectInView: cropRect,
                            isCropping: isCropping
                        ) ?? img

                        onAnalyse(finalImage)
                    } label: {
                        ZStack {
                            RoundedRectangle(
                                cornerRadius: Tokens.Radius.medium,
                                style: .continuous
                            )
                            .fill(Tokens.Color.accent)
                            .shadow(
                                color: Color.black,
                                radius: 0,
                                x: 2,
                                y: 2
                            )

                            HStack(spacing: 8.scale) {
                                Text("Check messages")
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
                    .disabled(image == nil)
                    .buttonStyle(OpacityTapButtonStyle())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 16.scale)
                    .padding(.bottom, 24.scale)

                }
                .padding(.top, 16.scale)
            }
        }
        .buttonStyle(OpacityTapButtonStyle())
    }
}

// MARK: - Geometry helpers (как в FaceSearchView)

private extension CheaterImagePreviewScreen {
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
