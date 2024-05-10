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

    private var requests = [UInt16: PingRequestStatus]() {
        didSet {
            guard requests.count == maxRequests else { return }
            guard requests.values.allSatisfy ({ if case .sent = $0 { false } else { true }}) else { return }
            callBack(.results(results))
        }
    }

    var results: [UInt16: Result<TimeInterval, Error>] {
        requests.reduce(into: [UInt16: Result<TimeInterval, Error>]()) { res, next in
            guard let val = next.value.response() else { return }
            res.updateValue(val, forKey: next.key)
        }
    }

    private var callBack: (PingRequestManagerCallBackType) -> Void

    init(maxRequests: Int, callBack: @escaping ((PingRequestManagerCallBackType) -> Void)) {
        self.maxRequests = maxRequests
        self.callBack = callBack
    }

    mutating func handleSent(request: Result<Date, Error>, for sequenceNumber: UInt16) {
        requests.updateValue(PingRequestStatus(request: request), forKey: sequenceNumber)
        callBack(.count(requests.count))
    }

    @discardableResult
    mutating func handleReceived(responseAt date: Date, for sequenceNumber: UInt16) -> TimeInterval? {
        guard case .sent(date: let sendTime) = requests[sequenceNumber] else { return nil }
        let elapsed = abs(sendTime.timeIntervalSince(date))
        requests.updateValue(.received(elapsed), forKey: sequenceNumber)
        return elapsed
    }

    mutating func updateResultsForTimeout() {
        for key in requests.keys {
            guard case .sent = requests[key] else { continue }
            requests.updateValue(.failed(PingSessionError.timeout), forKey: key)
        }
    }
}
