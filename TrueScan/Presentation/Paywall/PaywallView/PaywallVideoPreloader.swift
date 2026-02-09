//
//  PaywallVideoPreloader.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI
import AVFoundation
import UIKit

enum PaywallVideoPreloader {
    static let sharedAsset: AVURLAsset? = {
        guard let url = Bundle.main.url(forResource: "paywall_background", withExtension: "mp4") else {
            return nil
        }
        let asset = AVURLAsset(url: url)
        asset.loadValuesAsynchronously(forKeys: ["playable"]) { }
        return asset
    }()
}

final class PaywallLoopingPlayerView: UIView {
    private var player: AVQueuePlayer?
    private var looper: AVPlayerLooper?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let asset = PaywallVideoPreloader.sharedAsset
        guard
            let finalAsset = asset ?? {
                guard let url = Bundle.main.url(forResource: "paywall_background", withExtension: "mp4") else {
                    self.backgroundColor = .black
                    return nil
                }
                return AVURLAsset(url: url)
            }()
        else { return }

        let item = AVPlayerItem(asset: finalAsset)
        let player = AVQueuePlayer()
        let looper = AVPlayerLooper(player: player, templateItem: item)

        self.player = player
        self.looper = looper

        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        self.layer.addSublayer(layer)

        player.isMuted = true
        player.play()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        (layer.sublayers?.first as? AVPlayerLayer)?.frame = bounds
    }
}

struct PaywallVideoBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> PaywallLoopingPlayerView {
        PaywallLoopingPlayerView()
    }

    func updateUIView(_ uiView: PaywallLoopingPlayerView, context: Context) {}
}
