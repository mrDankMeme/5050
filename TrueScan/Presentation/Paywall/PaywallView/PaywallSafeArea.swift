//
//  PaywallSafeArea.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import UIKit

var topSafeInset: CGFloat {
    if Thread.isMainThread {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0
    } else {
        var inset: CGFloat = 0
        DispatchQueue.main.sync {
            inset = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0
        }
        return inset
    }
}
