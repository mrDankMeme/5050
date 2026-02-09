//  ImageCropper.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/02/25.
//

import UIKit
import SwiftUI
import CoreGraphics

// MARK: - ImageCropper
/// Единый конвейер «как в превью»:
/// 1) нормализация ориентации (EXIF -> .up),
/// 2) поворот на угол из SwiftUI (положительный = по часовой),
/// 3) (опционально) кроп по рамке, заданной во view-координатах,
/// 4) все преобразования через CGAffineTransform + inverse — без хардкод-кейсов 90/180/270.
struct ImageCropper {

    // MARK: - Публичный конвейер
    static func editedImage(
        source original: UIImage,
        imageViewSize: CGSize,
        rotation: Angle,
        userZoom: CGFloat,
        imageOffset: CGPoint,
        cropRectInView: CGRect,
        isCropping: Bool
    ) -> UIImage? {

        // 0) Нормализуем EXIF-ориентацию → пиксели как на экране, imageOrientation = .up
        let normalized = original.normalizedOrientation()

        // 1) Физический поворот bitmap (уже нормализованного).
        // SwiftUI: +angle = визуально по часовой. В CoreGraphics используем отрицательный угол,
        // чтобы визуальный результат совпал с превью.
        let rotated = rotate(source: normalized, rotationCW: rotation) ?? normalized

        // 2) Кроп (если активирован): уже на ПОВЁРНУТОМ изображении.
        guard isCropping else {
            return rotated
        }

        return cropUsingInvertedTransform(
            source: rotated,
            imageViewSize: imageViewSize,
            rotation: .zero,                 // поворот уже «вшит» в rotated
            userZoom: userZoom,
            imageOffset: imageOffset,
            cropRectInView: cropRectInView
        )
    }

    // MARK: - Поворот
    /// Поворачивает bitmap «как в превью»:
    /// rotationCW — SwiftUI угол (положительный = по часовой стрелке).
    /// На входе ожидается изображение c imageOrientation == .up (см. normalizedOrientation()).
    static func rotate(source original: UIImage, rotationCW: Angle) -> UIImage? {
        guard let cg = original.cgImage else { return nil }

        // Нормализуем до кратных 90 — у тебя кнопки по 90 градусов.
        let degCW = ((Int(round(rotationCW.degrees)) % 360) + 360) % 360

        // Если угол 0° — просто возвращаем нормализованное изображение
        if degCW == 0 {
            return original
        }

        // CoreGraphics использует «математический» знак (плюс = против часовой),
        // поэтому для визуального поворота по часовой используем отрицательный угол.
        let radians = -CGFloat(Double(degCW) * .pi / 180.0)

        let w = CGFloat(cg.width)
        let h = CGFloat(cg.height)
        let outSize: CGSize =
            (degCW == 90 || degCW == 270)
            ? CGSize(width: h, height: w)
            : CGSize(width: w, height: h)

        let colorSpace = cg.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: Int(outSize.width),
            height: Int(outSize.height),
            bitsPerComponent: cg.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        // Ставим центр выходного полотна в (0,0), вращаем, затем рисуем исходник с переносом к центру.
        ctx.translateBy(x: outSize.width / 2, y: outSize.height / 2)
        ctx.rotate(by: radians)
        ctx.translateBy(x: -w / 2, y: -h / 2)
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))

        guard let outImage = ctx.makeImage() else { return nil }
        return UIImage(cgImage: outImage, scale: original.scale, orientation: .up)
    }

    // MARK: - Кроп через инверсию трансформа
    /// Строим transform из image-space → view-space:
    ///   T = Translate(viewCenter) * Scale(S) * Rotate(radiansUI) * Translate(-imageCenter)
    /// где S = min(viewW/rotW, viewH/rotH) * userZoom.
    /// Затем берём T^-1 и прогоняем четыре угла cropRectInView в image-space.
    private static func cropUsingInvertedTransform(
        source original: UIImage,
        imageViewSize: CGSize,
        rotation: Angle,
        userZoom: CGFloat,
        imageOffset: CGPoint,
        cropRectInView: CGRect
    ) -> UIImage? {

        guard let cg = original.cgImage else { return nil }

        let w0 = CGFloat(cg.width)
        let h0 = CGFloat(cg.height)
        let imgCenter = CGPoint(x: w0 / 2, y: h0 / 2)
        let viewCenter = CGPoint(x: imageViewSize.width / 2, y: imageViewSize.height / 2)

        // Для rotated (мы уже передаём rotated и rotation = .zero),
        // но оставляю универсальность: размер rotated-прямоугольника до масштабирования.
        let degCW = ((Int(round(rotation.degrees)) % 360) + 360) % 360
        let swapWH = (degCW == 90 || degCW == 270)
        let rotW = swapWH ? h0 : w0
        let rotH = swapWH ? w0 : h0

        let baseScale = min(imageViewSize.width / max(rotW, 1),
                            imageViewSize.height / max(rotH, 1))
        let S = baseScale * max(userZoom, 0.0001)

        // Визуально по часовой = отрицательный угол для CGAffineTransform.
        let radiansUI = -CGFloat(rotation.radians)

        // Image-space -> View-space
        var T = CGAffineTransform.identity
        T = T.translatedBy(x: viewCenter.x, y: viewCenter.y)
        T = T.scaledBy(x: S, y: S)
        T = T.rotated(by: radiansUI)
        T = T.translatedBy(x: -imgCenter.x, y: -imgCenter.y)
        // Сдвиг пальцем/панорамой, если когда-то будет добавлен:
        T = T.translatedBy(x: imageOffset.x / max(1, 1), y: imageOffset.y / max(1, 1))

        guard let Tinverse = T.invertedIfPossible else { return nil }

        // Трансформируем углы cropRect из view-space в image-space
        let p1 = CGPoint(x: cropRectInView.minX, y: cropRectInView.minY).applying(Tinverse)
        let p2 = CGPoint(x: cropRectInView.maxX, y: cropRectInView.minY).applying(Tinverse)
        let p3 = CGPoint(x: cropRectInView.maxX, y: cropRectInView.maxY).applying(Tinverse)
        let p4 = CGPoint(x: cropRectInView.minX, y: cropRectInView.maxY).applying(Tinverse)

        var crop = CGRect.enclosing(points: [p1, p2, p3, p4]).integral

        // Клампим в границы битмапы
        let bounds = CGRect(x: 0, y: 0, width: w0, height: h0)
        crop = crop.intersection(bounds)
        if crop.isEmpty || !crop.isFinite { return nil }
        if crop.width <= 1 || crop.height <= 1 { return nil }

        guard let clipped = cg.cropping(to: crop) else { return nil }
        return UIImage(cgImage: clipped, scale: original.scale, orientation: .up)
    }
}

// MARK: - Utils

private extension CGRect {
    static func enclosing(points: [CGPoint]) -> CGRect {
        guard var r = points.first.map({ CGRect(origin: $0, size: .zero) }) else { return .null }
        for p in points.dropFirst() {
            r = r.union(CGRect(origin: p, size: .zero))
        }
        return r
    }

    var isFinite: Bool {
        !(origin.x.isNaN || origin.y.isNaN || size.width.isNaN || size.height.isNaN ||
          origin.x.isInfinite || origin.y.isInfinite || size.width.isInfinite || size.height.isInfinite)
    }
}

private extension CGAffineTransform {
    var isInvertible: Bool { abs(a * d - b * c) > .ulpOfOne }
    var invertedIfPossible: CGAffineTransform? { isInvertible ? inverted() : nil }
}

// MARK: - UIImage orientation normalization

private extension UIImage {
    /// Приводит изображение к imageOrientation == .up,
    /// при этом визуально картинка остаётся такой же, как её рисует UIKit/SwiftUI.
    func normalizedOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

/// ВАЖНО:
/// В проекте уже есть SwiftUI.ContentMode (.fit/.fill).
/// Раньше тут был `public enum ContentMode`, который перекрывал SwiftUI.ContentMode
/// и ломал компиляцию в местах типа `.aspectRatio(contentMode: .fill)`.
/// Поэтому оставляем (если вдруг понадобится) отдельное имя, чтобы не конфликтовать.
public enum CropperContentMode {
    case fit
}
