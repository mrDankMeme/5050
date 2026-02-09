//
//  TaskPoller.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

protocol TaskPoller {
    func waitForAnalyzeResult(taskId: UUID, interval: TimeInterval) async throws -> TaskReadDTO
    func waitForReverseResult(taskId: UUID, interval: TimeInterval) async throws -> ReverseSearchGetResponse
}
