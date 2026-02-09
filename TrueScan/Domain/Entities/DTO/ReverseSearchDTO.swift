//  ReverseSearchDTO.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

struct ReverseSearchCreateResponse: Codable {
    let task_id: UUID
}

struct ReverseSearchGetResponse: Codable {

    struct EnginesStatus: Codable {
        let google: String
        let yandex: String
        let bing: String
    }

    // Google
    struct Google: Codable {
        struct VisualMatch: Codable {
            let position: Int
            let title: String
            let link: String
            let source: String
            let thumbnail: String?
        }
        let visual_matches: [VisualMatch]?
    }

    // Yandex
    struct Yandex: Codable {
        struct ImageResult: Codable {
            struct Thumb: Codable {
                let link: String?
            }
            let title: String
            let link: String
            let source: String
            let thumbnail: Thumb?
        }
        let image_results: [ImageResult]?
    }

    // Bing
    struct Bing: Codable {
        struct RelatedContent: Codable {
            let position: Int?
            let title: String
            let link: String
            let thumbnail: String?
            let source: String?
        }
        let related_content: [RelatedContent]?
    }

    let status: EnginesStatus
    let results: Results

    struct Results: Codable {
        let google: Google?
        let yandex: Yandex?
        let bing: Bing?
    }
}
