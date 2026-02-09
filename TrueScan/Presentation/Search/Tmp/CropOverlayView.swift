//
//  CropOverlayView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/2/25.
//


//
//  CropOverlayView.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/02/25.
//

import SwiftUI

struct CropOverlayView: View {
    let cropRect: CGRect
    let lineWidth: CGFloat

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Полупрозрачная маска с "дыркой"
                Path { path in
                    path.addRect(CGRect(origin: .zero, size: geo.size))
                    path.addRect(cropRect)
                }
                .fill(Color.black.opacity(0.5), style: FillStyle(eoFill: true))

                // Рамка
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Tokens.Color.accent, lineWidth: lineWidth)
                    .frame(width: cropRect.width, height: cropRect.height)
                    .position(x: cropRect.midX, y: cropRect.midY)
            }
        }
        .allowsHitTesting(false)
    }
}
