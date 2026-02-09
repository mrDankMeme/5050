//  SearchService.swift
//  CheaterBuster
//

import Combine
import Foundation

public protocol SearchService {
    func searchByName(_ query: String) -> AnyPublisher<[ImageHit], Error>
    func searchByImage(_ jpegData: Data) -> AnyPublisher<[ImageHit], Error>
}
