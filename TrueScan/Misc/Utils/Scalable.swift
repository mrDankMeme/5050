//  Scalable.swift
//  CheaterBuster
//

import UIKit

// MARK: - ScreenScale (простой кеш коэффициента, без акторов)
enum ScreenScale {
    /// Коэффициент масштабирования относительно дизайн-ширины.
    /// Конфигурируем один раз при старте приложения.
    static var ratio: CGFloat = 1.0

    /// Настройка скейла относительно дизайн-ширины (по умолчанию 375pt).
    /// Звать из AppDelegate / SceneDelegate / при старте, с главного потока.
    static func configure(designWidth: CGFloat = 375) {
        let currentWidth = UIScreen.main.bounds.width
        let base = max(1, designWidth)
        let value = currentWidth / base
        // Чуть ограничиваем, чтобы не улетало в космос
        ratio = max(0.5, min(1.8, value))
    }
}

// MARK: - Протокол

/// Любой тип, который умеет масштабироваться через `.scale`
protocol Scalable {
    var scale: Self { get }
}

// MARK: - Базовые типы

extension CGFloat: Scalable {
    var scale: CGFloat {
        return self * ScreenScale.ratio
    }
}

extension Int {
    var scale: CGFloat {
        return CGFloat(self).scale
    }
}

extension Double {
    var scale: CGFloat {
        return CGFloat(self).scale
    }
}

extension CGPoint: Scalable {
    var scale: CGPoint {
        return CGPoint(x: x.scale, y: y.scale)
    }
}

extension CGSize: Scalable {
    var scale: CGSize {
        return CGSize(width: width.scale, height: height.scale)
    }
}

extension CGRect: Scalable {
    var scale: CGRect {
        return CGRect(origin: origin.scale, size: size.scale)
    }
}

extension UIFont {
    var scale: UIFont {
        let newSize = pointSize.scale
        return UIFont(name: fontName, size: newSize) ?? UIFont.systemFont(ofSize: newSize)
    }
}

extension UIEdgeInsets: Scalable {
    var scale: UIEdgeInsets {
        return UIEdgeInsets(
            top: top.scale,
            left: left.scale,
            bottom: bottom.scale,
            right: right.scale
        )
    }
}
