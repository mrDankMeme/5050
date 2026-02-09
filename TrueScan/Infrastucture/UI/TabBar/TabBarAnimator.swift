//  TabBarAnimator.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/1/25.
//

import UIKit

enum TabBarAnimator {

    static func set(slidDown: Bool, duration: TimeInterval = 0.25) {
        DispatchQueue.main.async {
            guard let tabBarController = findTabBarController() else { return }
            let tabBar = tabBarController.tabBar

            let h = tabBar.bounds.height
            let transform = slidDown
                ? CGAffineTransform(translationX: 0, y: h + 20)
                : .identity

            UIView.animate(withDuration: duration) {
                tabBar.transform = transform
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
