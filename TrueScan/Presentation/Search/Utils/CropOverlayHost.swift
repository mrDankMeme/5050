//
//  CropHandle.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/2/25.
//


import SwiftUI

enum CropHandle {
    case none, move, tl, tr, bl, br, top, bottom, left, right
}

struct CropOverlayHost: View {
    @Binding var isCropping: Bool
    @Binding var cropRect: CGRect

    let previewSize: CGSize
    let rotationAngle: Angle
    let userZoom: CGFloat
    let minCropSize: CGFloat
    let cropInset: CGFloat

    let imageVisibleRect: (_ container: CGSize, _ rotatedImageSize: CGSize) -> CGRect
    let rotatedBaseSize: () -> CGSize
    let initialCropRect: (_ container: CGSize, _ image: UIImage, _ rotation: Angle, _ zoom: CGFloat) -> CGRect

    // Состояние жеста
    @State private var activeHandle: CropHandle = .none
    @State private var dragStartRect: CGRect = .zero
    @State private var dragStartPoint: CGPoint = .zero

    // Хит-зоны (со скейлом)
    private let edgeHit: CGFloat = 22.scale
    private let cornerHit: CGFloat = 28.scale

    var body: some View {
        let visibleRect = imageVisibleRect(previewSize, rotatedBaseSize())

        Group {
            if isCropping {
                ZStack {
                    CropOverlayView(cropRect: cropRect, lineWidth: 0.scale)

                    
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(globalDrag(in: visibleRect))
                }
                .onAppear {
                    var t = Transaction(); t.disablesAnimations = true
                    withTransaction(t) {
                        cropRect = cropRect.isEmpty
                        ? visibleRect.insetBy(dx: cropInset, dy: cropInset).fitting(minSide: minCropSize)
                        : cropRect.clamped(to: visibleRect, minSide: minCropSize)
                    }
                }
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.9), value: isCropping)
    }

    // MARK: выбор хэндла
    private func handle(at p: CGPoint, in rect: CGRect) -> CropHandle {
        // Углы
        let tl = CGRect(x: rect.minX - cornerHit, y: rect.minY - cornerHit, width: 2 * cornerHit, height: 2 * cornerHit)
        let tr = CGRect(x: rect.maxX - cornerHit, y: rect.minY - cornerHit, width: 2 * cornerHit, height: 2 * cornerHit)
        let bl = CGRect(x: rect.minX - cornerHit, y: rect.maxY - cornerHit, width: 2 * cornerHit, height: 2 * cornerHit)
        let br = CGRect(x: rect.maxX - cornerHit, y: rect.maxY - cornerHit, width: 2 * cornerHit, height: 2 * cornerHit)
        if tl.contains(p) { return .tl }
        if tr.contains(p) { return .tr }
        if bl.contains(p) { return .bl }
        if br.contains(p) { return .br }

        
        let top = CGRect(x: rect.minX + edgeHit, y: rect.minY - edgeHit, width: max(0, rect.width - 2 * edgeHit), height: 2 * edgeHit)
        let bottom = CGRect(x: rect.minX + edgeHit, y: rect.maxY - edgeHit, width: max(0, rect.width - 2 * edgeHit), height: 2 * edgeHit)
        let left = CGRect(x: rect.minX - edgeHit, y: rect.minY + edgeHit, width: 2 * edgeHit, height: max(0, rect.height - 2 * edgeHit))
        let right = CGRect(x: rect.maxX - edgeHit, y: rect.minY + edgeHit, width: 2 * edgeHit, height: max(0, rect.height - 2 * edgeHit))
        if top.contains(p) { return .top }
        if bottom.contains(p) { return .bottom }
        if left.contains(p) { return .left }
        if right.contains(p) { return .right }

        
        if rect.contains(p) { return .move }
        return .none
    }

 
    private func globalDrag(in bounds: CGRect) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if activeHandle == .none {
                    activeHandle = handle(at: value.startLocation, in: cropRect)
                    dragStartRect = cropRect
                    dragStartPoint = value.startLocation
                }
                guard activeHandle != .none else { return }

                let dx = value.location.x - dragStartPoint.x
                let dy = value.location.y - dragStartPoint.y
                var r = dragStartRect

                switch activeHandle {
                case .move:
                    r.origin.x += dx; r.origin.y += dy
                case .tl:
                    r.origin.x += dx; r.origin.y += dy
                    r.size.width  -= dx; r.size.height -= dy
                case .tr:
                    r.origin.y += dy
                    r.size.width  += dx; r.size.height -= dy
                case .bl:
                    r.origin.x += dx
                    r.size.width  -= dx; r.size.height += dy
                case .br:
                    r.size.width  += dx; r.size.height += dy
                case .top:
                    r.origin.y += dy; r.size.height -= dy
                case .bottom:
                    r.size.height += dy
                case .left:
                    r.origin.x += dx; r.size.width -= dx
                case .right:
                    r.size.width += dx
                case .none:
                    break
                }

                r = r.normalizedPositive().clamped(to: bounds, minSide: minCropSize)

                var t = Transaction(); t.disablesAnimations = true
                withTransaction(t) { cropRect = r }
            }
            .onEnded { _ in activeHandle = .none }
    }
}
