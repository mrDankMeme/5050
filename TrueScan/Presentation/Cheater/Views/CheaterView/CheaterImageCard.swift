//  CheaterImageCard.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/28/25.
//

import SwiftUI

struct CheaterImageCard: View {
    let image: UIImage

    
    private var outerCorner: CGFloat { Tokens.Radius.medium.scale }
    private var innerCorner: CGFloat { 8.scale}
    private var innerPadding: CGFloat { 16.scale }

    var body: some View {
        ZStack {

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: innerCorner, style: .continuous))
                .shadow(
                    color: Tokens.Color.blue,
                    radius: 0,
                    x: 2.scale,
                    y: 2.scale
                )
        }
    
        .frame(maxWidth: .infinity)
        //.aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, 8.scale)
    }
}
