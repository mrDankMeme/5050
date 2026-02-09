//
//  InteractivePopConfigurator.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 11/01/25.
//

import SwiftUI
import UIKit

struct InteractivePopConfigurator: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard
            let nav = uiViewController.navigationController,
            let pop = nav.interactivePopGestureRecognizer
        else { return }

        pop.isEnabled = true
        pop.delegate = nil
    }
}

public extension View {
    func enableInteractivePop() -> some View {
        background(InteractivePopConfigurator())
    }
}
