

//
//  CGRect+CropHelpers.swift
//  CheaterBuster
//

import CoreGraphics

extension CGRect {
    func clamped(to bounds: CGRect, minSide: CGFloat) -> CGRect {
        var r = self
        r.size.width = max(r.size.width, minSide)
        r.size.height = max(r.size.height, minSide)
        if r.width > bounds.width { r.size.width = bounds.width }
        if r.height > bounds.height { r.size.height = bounds.height }
        if r.minX < bounds.minX { r.origin.x = bounds.minX }
        if r.minY < bounds.minY { r.origin.y = bounds.minY }
        if r.maxX > bounds.maxX { r.origin.x = bounds.maxX - r.width }
        if r.maxY > bounds.maxY { r.origin.y = bounds.maxY - r.height }
        return r.integral
    }

    func normalizedPositive() -> CGRect {
        var r = self
        if r.width < 0 { r.origin.x += r.width; r.size.width = abs(r.width) }
        if r.height < 0 { r.origin.y += r.height; r.size.height = abs(r.height) }
        return r
    }

    func fitting(minSide: CGFloat) -> CGRect {
        var r = self
        let w = max(minSide, min(r.width, r.width))
        let h = max(minSide, min(r.height, r.height))
        let cx = r.midX, cy = r.midY
        r.size = CGSize(width: w, height: h)
        r.origin = CGPoint(x: cx - w/2, y: cy - h/2)
        return r.integral
    }
}
