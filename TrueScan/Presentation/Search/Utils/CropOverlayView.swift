//
//  CropOverlayView.swift
//  CheaterBuster
//

import SwiftUI

/// Затемнение + «дырка» по cropRect + розовая рамка + утолщённые уголки
struct CropOverlayView: View {
    let cropRect: CGRect
    let lineWidth: CGFloat

    private let cornerLength: CGFloat = 22   // базовая длина «ножки» угла (до скейла)
    private let cornerThickness: CGFloat = 6 // базовая толщина уголка (до скейла)

    var body: some View {
        GeometryReader { geo in
            // Локальные скейленые размеры
            let L = cornerLength.scale        // длина «ножки» уголка
            let t = cornerThickness.scale     // толщина уголка
            let lw = lineWidth.scale          // толщина основной рамки

            ZStack {
                // затемнение + вырез
                Path { path in
                    path.addRect(CGRect(origin: .zero, size: geo.size))
                    path.addRect(cropRect)
                }
                .fill(Color.black.opacity(0.5), style: FillStyle(eoFill: true))

                // основная рамка
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Tokens.Color.accent, lineWidth: lw)
                    .frame(width: cropRect.width, height: cropRect.height)
                    .position(x: cropRect.midX, y: cropRect.midY)

                // уголки
                corner(.topLeft,     L: L, t: t)
                corner(.topRight,    L: L, t: t)
                corner(.bottomLeft,  L: L, t: t)
                corner(.bottomRight, L: L, t: t)
            }
        }
        .allowsHitTesting(false)
    }

    private enum Corner { case topLeft, topRight, bottomLeft, bottomRight }

    @ViewBuilder
    private func corner(_ c: Corner, L: CGFloat, t: CGFloat) -> some View {
        let w = cropRect.width, h = cropRect.height
        let x = cropRect.minX,  y = cropRect.minY

        switch c {
        case .topLeft:
            Group {
                RoundedRectangle(cornerRadius: 0.scale)
                    .fill(Tokens.Color.accent)
                    .frame(width: L, height: t)
                    .position(x: x + L / 2, y: y + t / 2)
                RoundedRectangle(cornerRadius: 0.scale)
                    .fill(Tokens.Color.accent)
                    .frame(width: t, height: L)
                    .position(x: x + t / 2, y: y + L / 2)
            }
        case .topRight:
            Group {
                RoundedRectangle(cornerRadius: 0.scale)
                    .fill(Tokens.Color.accent)
                    .frame(width: L, height: t)
                    .position(x: x + w - L / 2, y: y + t / 2)
                RoundedRectangle(cornerRadius: 0.scale)
                    .fill(Tokens.Color.accent)
                    .frame(width: t, height: L)
                    .position(x: x + w - t / 2, y: y + L / 2)
            }
        case .bottomLeft:
            Group {
                RoundedRectangle(cornerRadius: 0.scale)
                    .fill(Tokens.Color.accent)
                    .frame(width: L, height: t)
                    .position(x: x + L / 2, y: y + h - t / 2)
                RoundedRectangle(cornerRadius: 0.scale)
                    .fill(Tokens.Color.accent)
                    .frame(width: t, height: L)
                    .position(x: x + t / 2, y: y + h - L / 2)
            }
        case .bottomRight:
            Group {
                RoundedRectangle(cornerRadius: 0.scale)
                    .fill(Tokens.Color.accent)
                    .frame(width: L, height: t)
                    .position(x: x + w - L / 2, y: y + h - t / 2)
                RoundedRectangle(cornerRadius: 0.scale)
                    .fill(Tokens.Color.accent)
                    .frame(width: t, height: L)
                    .position(x: x + w - t / 2, y: y + h - L / 2)
            }
        }
    }
}
