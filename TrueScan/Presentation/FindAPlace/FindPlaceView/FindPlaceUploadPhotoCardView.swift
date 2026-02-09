//
//  FindPlaceUploadPhotoCardView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/18/25.
//

import SwiftUI

struct FindPlaceUploadPhotoCardView: View {
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
