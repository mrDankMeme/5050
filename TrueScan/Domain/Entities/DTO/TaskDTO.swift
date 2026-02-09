//  TaskDTO.swift
//  CheaterBuster
//
//  Created by Niiaz Khasanov on 10/29/25.
//

import Foundation

// MARK: - TaskStatus

enum TaskStatus: Equatable {
    case queued
    case started
    case failed
    case finished
    case other(String)
}

extension TaskStatus: Codable {
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self).lowercased()
        switch raw {
        case "queued":
            self = .queued
        case "started", "running":
            self = .started
        case "finished", "completed":
            self = .finished
        case "failed":
            self = .failed
        default:
            self = .other(raw)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .queued:
            try c.encode("queued")
        case .started:
            try c.encode("started")
        case .failed:
            try c.encode("failed")
        case .finished:
            try c.encode("finished")
        case .other(let s):
            try c.encode(s)
        }
    }
}

// MARK: - TaskResult

struct TaskResult: Codable, Equatable {
    let risk_score: Int
    let red_flags: [String]
    let recommendations: [String]
}

// MARK: - TaskReadResult

enum TaskReadResult: Equatable {
    case details(TaskResult)
    case message(String)
    case none
}

extension TaskReadResult: Codable {
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let obj = try? c.decode(TaskResult.self) {
            self = .details(obj)
        } else if let msg = try? c.decode(String.self) {
            self = .message(msg)
        } else {
            self = .none
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .details(let d):
            try c.encode(d)
        case .message(let s):
            try c.encode(s)
        case .none:
            try c.encodeNil()
        }
    }
}

// MARK: - TaskReadDTO

struct TaskReadDTO: Codable, Equatable {
    let id: UUID
    let status: TaskStatus
    let result: TaskReadResult?
    let error: String?
}
