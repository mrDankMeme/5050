
//  TabBarEnvironment.swift
//  CheaterBuster
//
//  Создаёт bridge к UITabBar и пробрасывает его высоту в SwiftUI через Environment.

import SwiftUI
import UIKit

// MARK: - Environment key

private struct TabBarHeightKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    
    var tabBarHeight: CGFloat {
        get { self[TabBarHeightKey.self] }
        set { self[TabBarHeightKey.self] = newValue }
    }
}

// MARK: - TabBarAccessor


struct TabBarAccessor: UIViewControllerRepresentable {
    var callback: (UITabBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(
        context: UIViewControllerRepresentableContext<TabBarAccessor>
    ) -> UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(
        _ uiViewController: UIViewController,
        context: UIViewControllerRepresentableContext<TabBarAccessor>
    ) {
        
    }

    private final class ViewController: UIViewController {
        var callback: (UITabBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if let tabBar = self.tabBarController?.tabBar {
                callback(tabBar)
            }
        }
    }
}
