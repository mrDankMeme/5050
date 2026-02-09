//
//  OnboardingTitleTextBuilder.swift
//  TrueScan
//
//  Created by Niiaz Khasanov on 12/25/25.
//


import SwiftUI

enum OnboardingTitleTextBuilder {
    static func titleText(title: String, accentFragments: [String]?) -> Text {
        guard let fragments = accentFragments, !fragments.isEmpty else {
            return Text(title)
        }

        var ranges: [Range<String.Index>] = []

        for fragment in fragments {
            guard !fragment.isEmpty, let range = title.range(of: fragment) else { continue }
            if !ranges.contains(where: { $0.overlaps(range) }) {
                ranges.append(range)
            }
        }

        guard !ranges.isEmpty else { return Text(title) }

        ranges.sort { $0.lowerBound < $1.lowerBound }

        var result = Text("")
        var currentIndex = title.startIndex

        for range in ranges {
            if currentIndex < range.lowerBound {
                let prefix = String(title[currentIndex..<range.lowerBound])
                result = result + Text(prefix).foregroundStyle(Tokens.Color.textPrimary)
            }

            let accentPart = String(title[range])
            result = result + Text(accentPart).foregroundStyle(Tokens.Color.accent)

            currentIndex = range.upperBound
        }

        if currentIndex < title.endIndex {
            let suffix = String(title[currentIndex..<title.endIndex])
            result = result + Text(suffix).foregroundStyle(Tokens.Color.textPrimary)
        }

        return result
    }
}
