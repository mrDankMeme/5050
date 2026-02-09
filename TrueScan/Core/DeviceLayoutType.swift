//
//  DeviceLayoutType.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 11/22/25.
//


// Utilities/DeviceLayout.swift
// Универсальная утилита для распознавания типа экрана
// (маленький статус-бар, notch, Dynamic Island) по safe area.

import UIKit

enum DeviceLayoutType {
    /// Старые iPhone с кнопкой Home и маленьким статус-баром (~20pt),
    /// без home indicator снизу: iPhone 7 / 8 / SE 2 / SE 3 и т.п.
    case smallStatusBar
    
    /// iPhone с "чёлкой" (notch), но без Dynamic Island:
    /// iPhone X → 13, iPhone 14/15 non-Pro и т.п.
    case notch
    
    /// iPhone с Dynamic Island: 14 Pro / 14 Pro Max / 15 Pro / 15 Pro Max и т.п.
    case dynamicIsland
    
    /// На всякий случай fallback, если что-то пойдёт не так
    case unknown
}

struct DeviceLayout {
    
    // MARK: - Публичные шорткаты
    
    static var type: DeviceLayoutType {
        current()
    }
    
    static var isDynamicIsland: Bool {
        current() == .dynamicIsland
    }
    
    static var isNotch: Bool {
        current() == .notch
    }
    
    /// Это как раз то, что тебе нужно для iPhone 7/8:
    /// маленький статус-бар ~20pt и нет home indicator снизу.
    static var isSmallStatusBarPhone: Bool {
        current() == .smallStatusBar
    }
    
    // MARK: - Основная логика
    
    /// Определяем тип устройства по safeAreaInsets.
    ///
    /// - `top`:
    ///   * ~20  — старые iPhone с кнопкой (7/8/SE)
    ///   * ~44  — обычный notch
    ///   * ~59+ — Dynamic Island (на текущих моделях)
    ///
    /// - `bottom`:
    ///   * 0    — нет home indicator (старые устройства)
    ///   * >0   — есть home indicator (Face ID / жестовая навигация)
    ///
    private static func current() -> DeviceLayoutType {
        guard let window = keyWindow else {
            return .unknown
        }
        
        let insets = window.safeAreaInsets
        let top = insets.top
        let bottom = insets.bottom
        
        // MARK: Dynamic Island
        //
        // На текущих моделях у Dynamic Island заметно больший top inset, чем у обычного notch.
        // Обычно это ~59pt и больше.
        if top >= 50, bottom > 0 {
            return .dynamicIsland
        }
        
        // MARK: Обычный notch (iPhone X → 13, 14/15 non-Pro)
        //
        // Классический "чёлочный" экран: top ~44, bottom > 0 (home indicator).
        if top >= 44, bottom > 0 {
            return .notch
        }
        
        // MARK: Маленький статус-бар (iPhone 7 / 8 / SE и подобные)
        //
        // Старые устройства с кнопкой Home:
        // top ≈ 20, bottom == 0 (нет home indicator).
        if top <= 20, bottom == 0 {
            return .smallStatusBar
        }
        
        return .unknown
    }
    
    // MARK: - Поиск keyWindow (корректно для iOS 13+ с несколькими сценами)
    
    private static var keyWindow: UIWindow? {
        // Берём первую активную UIWindowScene с keyWindow
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        
        // В каждой сцене ищем window.isKeyWindow == true
        for scene in scenes {
            if let key = scene.windows.first(where: { $0.isKeyWindow }) {
                return key
            }
        }
        
        // Fallback (на всякий случай)
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
}
