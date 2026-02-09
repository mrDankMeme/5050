//  TabBarTransparencyAnimator.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/15/25.
//

import UIKit

enum TabBarTransparencyAnimator {

    static func setTransparent(_ transparent: Bool, duration: TimeInterval = 0.25) {
        DispatchQueue.main.async {
            guard let tabBarController = findTabBarController() else { return }
            let tabBar = tabBarController.tabBar

            let alpha: CGFloat = transparent ? 0.0 : 1.0
            UIView.animate(withDuration: duration) {
                tabBar.alpha = alpha
            }
        }
    }

    // MARK: - Поиск UITabBarController

    private static func findTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
              let window = windowScene.keyWindow
        else { return nil }

        return window.rootViewController as? UITabBarController
            ?? window.rootViewController?.children.compactMap { $0 as? UITabBarController }.first
    }
}
