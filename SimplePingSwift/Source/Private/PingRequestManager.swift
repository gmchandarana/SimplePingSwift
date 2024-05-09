//
//  PingRequestManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 08/05/2024.
//

import Foundation

enum PingRequestManagerCallBackType {
    case count(Int)
    case results([UInt16: Result<TimeInterval, Error>])
}

struct PingRequestManager {

    let maxRequests: Int
    private var successfulRequests: [UInt16: Date] = [:]
    private var unsuccessfulRequests: [UInt16: Error] = [:]
    private (set) var results: [UInt16: Result<TimeInterval, Error>] = [:] {
        didSet {
            guard results.count == maxRequests else { return }
            callBack(.results(results))
        }
    }

    private var callBack: (PingRequestManagerCallBackType) -> Void
    private var totalRequests: Int { successfulRequests.count + unsuccessfulRequests.count }

    init(maxRequests: Int, callBack: @escaping ((PingRequestManagerCallBackType) -> Void)) {
        self.maxRequests = maxRequests
        self.callBack = callBack
    }

    mutating func addSent(request: Result<Date, Error>, for packet: UInt16) {
        switch request {
        case .success(let success): successfulRequests.updateValue(success, forKey: packet)
        case .failure(let failure):
            unsuccessfulRequests.updateValue(failure, forKey: packet)
            results.updateValue(.failure(failure), forKey: packet)
        }
        callBack(.count(totalRequests))
    }

    mutating func handleReceivedResponse(at: Date, for packet: UInt16) -> TimeInterval? {
        guard let sendTime = requestTimeFor(packet: packet) else { return nil }
        let elapsed = abs(sendTime.timeIntervalSinceNow)
        results.updateValue(.success(elapsed), forKey: packet)
        return elapsed
    }

    func requestTimeFor(packet: UInt16) -> Date? {
        successfulRequests[packet]
    }

    func failureReasonFor(packet: UInt16) -> Error? {
        unsuccessfulRequests[packet]
    }

    mutating func updateResultsForTimeout() {
        let resultKeys = results.keys
        let timeoutRequests = successfulRequests.filter { !resultKeys.contains($0.key) }
        for request in timeoutRequests {
            results.updateValue(.failure(PingSessionError.timeout), forKey: request.key)
        }
    }
}
