//
//  FindPlaceRootContentView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/18/25.
//



import SwiftUI

struct FindPlaceRootContentView: View {

    let onClose: () -> Void
    let onUploadTap: () -> Void
    let onBottomTap: () -> Void

    let hasUploadedImage: Bool

    init(
        onClose: @escaping () -> Void,
        onUploadTap: @escaping () -> Void,
        onBottomTap: @escaping () -> Void,
        hasUploadedImage: Bool
    ) {
        self.onClose = onClose
        self.onUploadTap = onUploadTap
        self.onBottomTap = onBottomTap
        self.hasUploadedImage = hasUploadedImage
    }

    var body: some View {
        VStack(spacing: 24.scale) {
            FindPlaceHeaderView(title: "Find a Place", onClose: onClose)

            Button {
                onUploadTap()
            } label: {
                FindPlaceUploadPhotoCardView()
            }
            .buttonStyle(OpacityTapButtonStyle())
            .frame(maxWidth: .infinity, alignment: .center)

            Spacer(minLength: 0)

           
            FindPlaceBottomView(title: "Find a Place", onTap: onBottomTap)
                .opacity(hasUploadedImage ? 1.0 : 0.5)
                .allowsHitTesting(hasUploadedImage)
        }
        .padding(.horizontal, Tokens.Spacing.x16)
        .padding(.top, Tokens.Spacing.x8)
        .padding(.bottom, 24.scale)
        .ignoresSafeArea(edges: .bottom)
    }
}
