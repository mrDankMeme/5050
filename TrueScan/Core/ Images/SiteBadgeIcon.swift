//
//  SiteBadgeIcon.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/26/25.
//

import SwiftUI
import UIKit

// MARK: - Badge UI (иконка сайта)

struct SiteBadgeIcon: View {
    let url: URL

    
    private let side: CGFloat = 26.scale

    
    private let innerSide: CGFloat = 18.scale

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.08), lineWidth: 1 / UIScreen.main.scale)
                )
                .shadow(color: Color.black.opacity(0.10), radius: 6.scale, x: 0, y: 2.scale)

            CachedRemoteImageView(
                url: url,
                
                contentMode: .fill,
                placeholder: AnyView(
                    Image(systemName: "globe")
                        .font(.system(size: 12.scale, weight: .medium))
                        .foregroundStyle(Color.black.opacity(0.45))
                )
            )
            .frame(width: innerSide, height: innerSide)
            .clipShape(Circle())
        }
        .frame(width: side, height: side)
        .accessibilityIdentifier("siteBadge")
    }
}

// MARK: - URL resolving (icon -> fallback favicon -> last resort)

enum SiteBadgeURLResolver {

    static func resolve(
        iconURLString: String?,
        linkURLString: String?,
        previewText: String?
    ) -> URL? {
        
        if let s = iconURLString, let u = URL(string: s), u.scheme != nil {
            return u
        }

        
        if let s = linkURLString, let u = URL(string: s),
           let host = u.host, host.isEmpty == false {
            return faviconURL(forHost: host)
        }

        
        if let host = extractHostFromPreview(previewText), host.isEmpty == false {
            return faviconURL(forHost: host)
        }

        return nil
    }

    static func resolve(iconURL: URL?, linkURL: URL?) -> URL? {
        if let iconURL, iconURL.scheme != nil {
            return iconURL
        }
        if let linkURL, let host = linkURL.host, host.isEmpty == false {
            return faviconURL(forHost: host)
        }
        return nil
    }

    private static func faviconURL(forHost host: String) -> URL? {
        
        var comps = URLComponents(string: "https://www.google.com/s2/favicons")
        comps?.queryItems = [
            URLQueryItem(name: "sz", value: "128"),
            URLQueryItem(name: "domain_url", value: host)
        ]
        return comps?.url
    }

    private static func extractHostFromPreview(_ preview: String?) -> String? {
        guard let preview, preview.isEmpty == false else { return nil }

        if let u = URL(string: preview), let host = u.host {
            return host
        }
        if let u = URL(string: "https://" + preview), let host = u.host {
            return host
        }
        return nil
    }
}
