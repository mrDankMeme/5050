//
//  SettingsSafariAndShare.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI
import SafariServices

struct SafariItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct SafariView: UIViewControllerRepresentable {
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

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
