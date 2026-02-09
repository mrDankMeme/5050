//
//  UIRoundedTabBarController.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 11/15/25.
//


import UIKit

final class UIRoundedTabBarController: UITabBarController {

    private let shadowId = "RoundedTabBarShadow"

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let tabBar = self.tabBar

        
        tabBar.layer.cornerRadius = 28
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.layer.masksToBounds = true

        addShadowBelow(tabBar: tabBar)
    }

    private func addShadowBelow(tabBar: UITabBar) {
        if let shadow = view.subviews.first(where: { $0.accessibilityIdentifier == shadowId }) {
            shadow.frame = tabBar.frame
            return
        }

        let shadowView = UIView(frame: tabBar.frame)
        shadowView.accessibilityIdentifier = shadowId

        shadowView.backgroundColor = tabBar.backgroundColor ?? .white
        shadowView.layer.cornerRadius = tabBar.layer.cornerRadius
        shadowView.layer.maskedCorners = tabBar.layer.maskedCorners
        shadowView.layer.masksToBounds = false

        shadowView.layer.shadowColor = UIColor.black.withAlphaComponent(0.12).cgColor
        shadowView.layer.shadowOpacity = 1
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -4)
        shadowView.layer.shadowRadius = 16

        view.addSubview(shadowView)
        view.bringSubviewToFront(tabBar)
    }
}
