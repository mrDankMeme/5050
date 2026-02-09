//
//  FaviconURLBuilder.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import Foundation

/// Унифицированный способ получить "лого сайта" (favicon) по URL результата.
/// Мы НЕ полагаемся на конкретный бек (Google/Yandex/Bing),
/// потому что в текущих DTO в проекте source_icon не прокинут.
///
/// Здесь используем стабильный favicon endpoint от Google:
/// https://www.google.com/s2/favicons?domain=<domain>&sz=64
///
/// Плюсы:
/// - не нужно менять API
/// - работает для большинства доменов
/// - всегда один формат URL
enum FaviconURLBuilder {

    static func faviconURL(for pageURL: URL?, size: Int = 64) -> URL? {
        guard let pageURL else { return nil }
        guard let host = pageURL.host?.trimmingCharacters(in: .whitespacesAndNewlines),
              !host.isEmpty
        else { return nil }

        var comps = URLComponents(string: "https://www.google.com/s2/favicons")
        comps?.queryItems = [
            URLQueryItem(name: "domain", value: host),
            URLQueryItem(name: "sz", value: "\(max(16, min(size, 256)))")
        ]
        return comps?.url
    }

    static func faviconURLString(for pageURL: URL?, size: Int = 64) -> String? {
        faviconURL(for: pageURL, size: size)?.absoluteString
    }
}
