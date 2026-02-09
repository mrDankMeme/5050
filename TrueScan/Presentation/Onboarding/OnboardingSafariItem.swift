//
//  OnboardingSafariItem.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//



import SwiftUI
import SafariServices
import UIKit

struct OnboardingSafariItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct OnboardingSafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let cfg = SFSafariViewController.Configuration()
        cfg.entersReaderIfAvailable = false
        let vc = SFSafariViewController(url: url, configuration: cfg)
        vc.preferredControlTintColor = UIColor(Tokens.Color.accent)
        vc.dismissButtonStyle = .done
        return vc
    }

    func updateUIViewController(_ vc: SFSafariViewController, context: Context) {}
}
