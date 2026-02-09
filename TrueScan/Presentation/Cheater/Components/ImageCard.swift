//
//  ImageCard.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/31/25.
//


import SwiftUI

struct ImageCard: View {
    let image: UIImage
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                .fill(Tokens.Color.surfaceCard)
                .overlay(
                    RoundedRectangle(cornerRadius: Tokens.Radius.medium.scale, style: .continuous)
                        .stroke(Tokens.Color.borderNeutral, lineWidth: 1.scale)
                )
                .apply(Tokens.Shadow.card)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 200.scale, maxHeight: 400.scale) // из макета
                .clipped()
                .cornerRadius(Tokens.Radius.small.scale)
                .padding(16.scale)
        }
        .padding(.horizontal, 8.scale)
    }
}
