//
//  RoundedTabView.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 11/15/25.
//


import SwiftUI

struct RoundedTabView<Content: View>: UIViewControllerRepresentable {

    let content: () -> Content

    func makeUIViewController(context: Context) -> UIRoundedTabBarController {
        let controller = UIRoundedTabBarController()
        let hosting = UIHostingController(rootView: content())
        controller.setViewControllers([hosting], animated: false)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIRoundedTabBarController, context: Context) {
        if let hosting = uiViewController.viewControllers?.first as? UIHostingController<Content> {
            hosting.rootView = content()
        }
    }
}
