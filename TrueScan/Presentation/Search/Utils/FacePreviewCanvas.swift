//
//  FacePreviewCanvas.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/2/25.
//


import SwiftUI

struct FacePreviewCanvas: View {
    let image: UIImage?

    @Binding var rotationAngle: Angle
    @Binding var userZoom: CGFloat
    @Binding var isCropping: Bool
    @Binding var cropRect: CGRect
    @Binding var previewSize: CGSize

    let minCropSize: CGFloat
    let cropInset: CGFloat

    
    let imageVisibleRect: (_ container: CGSize, _ rotatedImageSize: CGSize) -> CGRect
    let rotatedBaseSize: () -> CGSize
    let initialCropRect: (_ container: CGSize, _ image: UIImage, _ rotation: Angle, _ zoom: CGFloat) -> CGRect

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let uiImage = image {
                    let baseSize: CGSize = {
                        let deg = abs(Int(rotationAngle.degrees)) % 360
                        let swap = (deg == 90 || deg == 270)
                        return CGSize(width: swap ? uiImage.size.height : uiImage.size.width,
                                      height: swap ? uiImage.size.width  : uiImage.size.height)
                    }()

                    let scale: CGFloat = {
                        let s = min(geo.size.width / baseSize.width, geo.size.height / baseSize.height)
                        return s * userZoom
                    }()

                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(width: uiImage.size.width, height: uiImage.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 18.scale, style: .continuous))
                        .shadow(
                            color: Tokens.Color.blue,
                            radius: 0,
                            x: 4.scale,
                            y: 4.scale
                        )
                        .rotationEffect(rotationAngle)
                        .scaleEffect(scale)
                        .frame(width: geo.size.width, height: geo.size.height)

                    CropOverlayHost(
                        isCropping: $isCropping,
                        cropRect: $cropRect,
                        previewSize: geo.size,
                        rotationAngle: rotationAngle,
                        userZoom: userZoom,
                        minCropSize: minCropSize,
                        cropInset: cropInset,
                        imageVisibleRect: imageVisibleRect,
                        rotatedBaseSize: rotatedBaseSize,
                        initialCropRect: initialCropRect
                    )
                } else {
                    ContentUnavailableView(
                        "Select a photo",
                        systemImage: "photo",
                        description: Text("Pick one image to search by face.")
                    )
                }
            }
            .onAppear { previewSize = geo.size }
            .onChange(of: geo.size) { _, new in previewSize = new }
        }
    }
}
