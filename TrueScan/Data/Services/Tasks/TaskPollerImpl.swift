// Domain/Tasks/TaskPollerImpl.swift
// CheaterBuster
//



import Foundation

// MARK: - Lightweight backoff helper
private struct Backoff {
    private(set) var current: TimeInterval
    private let factor: Double
    private let maxDelay: TimeInterval
    private let jitter: ClosedRange<Double>

    init(start: TimeInterval = 10,
         factor: Double = 2,
         maxDelay: TimeInterval = 120,
         jitter: ClosedRange<Double> = 0.85...1.15) {
        self.current = start
        self.factor = factor
        self.maxDelay = maxDelay
        self.jitter = jitter
    }

    mutating func nextDelay() -> TimeInterval {
        let j = Double.random(in: jitter)
        let next = min(current * factor, maxDelay) * j
        current = max(0.5, next)
        return current
    }
}

// MARK: - TaskPollerImpl

final class TaskPollerImpl: TaskPoller {
    private let api: CheaterAPI

    
    private let defaultMaxDuration: TimeInterval = 75
    private let defaultMaxServerErrors: Int = 2

    init(api: CheaterAPI) { self.api = api }

    
    func waitForAnalyzeResult(taskId: UUID, interval: TimeInterval) async throws -> TaskReadDTO {
        try await waitForAnalyzeResultInternal(
            taskId: taskId,
            startInterval: max(0.8, interval),
            maxDuration: defaultMaxDuration,
            maxServerErrors: defaultMaxServerErrors
        )
    }

    // MARK: - PUBLIC (протокол): Reverse
    func waitForReverseResult(taskId: UUID, interval: TimeInterval) async throws -> ReverseSearchGetResponse {
        
        try await waitForReverseResultInternal(
            taskId: taskId,
            startInterval: max(15.0, interval),     

            maxDuration: defaultMaxDuration,
            maxServerErrors: defaultMaxServerErrors
        )
    }

    // MARK: - INTERNAL Analyze
    private func waitForAnalyzeResultInternal(
        taskId: UUID,
        startInterval: TimeInterval,
        maxDuration: TimeInterval,
        maxServerErrors: Int
    ) async throws -> TaskReadDTO {
        let started = Date()
        var backoff = Backoff(start: 10.0, factor: 2.0, maxDelay: 120.0, jitter: 1.0...1.0)

        var consecutive5xx = 0

        while true {
            try Task.checkCancellation()

            if Date().timeIntervalSince(started) > maxDuration {
                throw timeoutError("analyze", seconds: maxDuration)
            }

            do {
                let state = try await api.getAnalyzeTask(id: taskId)

                switch state.status {
                case .finished, .failed:
                    return state
                case .queued, .started, .other:
                    let delay = backoff.current
                    debug("⏳ analyze poll sleep \(String(format: "%.2fs", delay))")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    _ = backoff.nextDelay()
                }

                consecutive5xx = 0
            } catch {
                if isServerError(error) {
                    consecutive5xx += 1
                    debug("⚠️ analyze poll 5xx #\(consecutive5xx)")
                    if consecutive5xx >= maxServerErrors {
                        throw error
                    }
                    let delay = backoff.current + 2.0
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    _ = backoff.nextDelay()
                    continue
                } else if isCancellation(error) {
                    throw error
                } else {
                    throw error
                }
            }
        }
    }

    // MARK: - INTERNAL Reverse
    private func waitForReverseResultInternal(
        taskId: UUID,
        startInterval: TimeInterval,
        maxDuration: TimeInterval,
        maxServerErrors: Int
    ) async throws -> ReverseSearchGetResponse {
        let started = Date()

        // 👇 Тёплый старт: перед первым GET ждём startInterval (минимум 5s из публичного метода)
        do { try await Task.sleep(nanoseconds: UInt64(startInterval * 1_000_000_000)) } catch {}

        // Дальше поллим с более мягким бэкоффом
        var backoff = Backoff(start: 2.0, factor: 1.6, maxDelay: 10)  // 👈 после первого GET шаги 2s → 3.2s → 5s → 8s → 10s
        var consecutive5xx = 0
        var lastSnapshot: ReverseSearchGetResponse?

        while true {
            try Task.checkCancellation()

            if Date().timeIntervalSince(started) > maxDuration {
                if let snap = lastSnapshot, snap.hasAnyVisuals {
                    debug("⏱ reverse poll timeout — return last snapshot (partial)")
                    return snap
                }
                throw timeoutError("reverse", seconds: maxDuration)
            }

            do {
                let r = try await api.getReverseSearch(id: taskId)
                lastSnapshot = r

                // Все завершили?
                let done = [r.status.google, r.status.yandex, r.status.bing]
                    .allSatisfy { $0.lowercased() == "completed" }
                if done { return r }

                // Ранний успех — как только есть хоть что-то визуальное
                if r.hasAnyVisuals {
                    debug("✅ reverse poll: good-enough — early return")
                    return r
                }

                let remaining = max(0, maxDuration - Date().timeIntervalSince(started))
                let delay = min(backoff.current, remaining > 0 ? remaining : 0.5)
                debug("⏳ analyze poll sleep \(String(format: "%.2fs", delay))")
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                _ = backoff.nextDelay()


                consecutive5xx = 0
            } catch {
                if isServerError(error) {
                    consecutive5xx += 1
                    debug("⚠️ reverse poll 5xx #\(consecutive5xx)")

                    // Если ещё не было ни одного валидного ответа — даём до 3 подряд 5xx
                    let allowed5xx = (lastSnapshot == nil) ? 3 : maxServerErrors
                    if consecutive5xx >= allowed5xx {
                        if let snap = lastSnapshot, snap.hasAnyVisuals {
                            debug("↩️ reverse poll: return last snapshot after 5xx")
                            return snap
                        }
                        throw error
                    }

                    // Агрессивный бэкофф на «холодном» старте
                    let delay = backoff.current + 2.0
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    _ = backoff.nextDelay()
                    continue
                } else if isCancellation(error) {
                    throw error
                } else {
                    throw error
                }
            }
        }
    }

    // MARK: - Helpers

    private func isServerError(_ error: Error) -> Bool {
        if case let APIError.http(code, _) = error, (500...599).contains(code) {
            return true
        }
        return false
    }


    private func isCancellation(_ error: Error) -> Bool {
        (error as NSError).domain == NSCocoaErrorDomain && (error as NSError).code == NSUserCancelledError
        || error is CancellationError
    }

    private func timeoutError(_ ctx: String, seconds: TimeInterval) -> NSError {
        NSError(domain: "cb.poller.timeout",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "\(ctx) polling timed out after \(Int(seconds))s"])

    }

    private func debug(_ msg: String) {
        #if DEBUG
        print(msg)
        #endif
    }
}

// MARK: - Convenience for ReverseSearchGetResponse

private extension ReverseSearchGetResponse {
    /// Проверяем «есть ли что-то визуально полезное» по РЕАЛЬНЫМ полям твоего DTO.
    var hasAnyVisuals: Bool {
        let g = results.google?.visual_matches?.isEmpty == false
        let y = results.yandex?.image_results?.isEmpty == false
        let b = results.bing?.related_content?.isEmpty == false
        return g || y || b
    }
}
