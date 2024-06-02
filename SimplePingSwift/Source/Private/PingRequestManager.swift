//
//  PingRequestManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 08/05/2024.
//

import Foundation

struct PingRequestManager {

    let maxCount: Int
    private (set) var requests = [UInt16: PingRequestStatus]()

    var hasReceivedAllResponses: Bool {
        requests.count == maxCount && requests.values.allSatisfy { if case .sent = $0 { false } else { true } }
    }

    var results: [UInt16: Result<TimeInterval, Error>] {
        requests.reduce(into: [UInt16: Result<TimeInterval, Error>]()) { res, next in
            guard let val = next.value.response() else { return }
            res.updateValue(val, forKey: next.key)
        }
    }

    mutating func handleSent(request: Result<Date, Error>, for sequenceNumber: UInt16) {
        requests.updateValue(PingRequestStatus(request: request), forKey: sequenceNumber)
    }

    @discardableResult
    mutating func handleReceived(response: Result<Date, Error>, for sequenceNumber: UInt16) -> TimeInterval? {
        switch response {
        case .success(let success):
            guard case .sent(date: let sendTime) = requests[sequenceNumber] else { return nil }
            let elapsed = abs(sendTime.timeIntervalSince(success))
            requests.updateValue(.received(elapsed), forKey: sequenceNumber)
            return elapsed
        case .failure(let failure):
            requests.updateValue(.failed(failure), forKey: sequenceNumber)
            return nil
        }
    }
}
