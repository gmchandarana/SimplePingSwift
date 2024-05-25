//
//  PingResult.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

public struct PingResult {
    public let host: String
    public let count: Int
    public let average: Double
    public let success: Double
    public let responses: [Result<TimeInterval, Error>]
}

extension PingResult {

    public init(host: String, responses: [UInt16: Result<TimeInterval, Error>]) {
        self.host = host
        self.count = responses.count
        self.responses = responses.map { $0.value }

        let successfulResponses = self.responses.compactMap {
            if case let .success(timeInterval) = $0 { timeInterval } else { nil }
        }

        self.average = successfulResponses.reduce(0, +)/Double(successfulResponses.count)
        self.success = Double(successfulResponses.count)/Double(count)
    }

}

extension PingResult: CustomStringConvertible {
    public var description: String {
        "PingResult(host: \(host), count: \(count), average: \(average), success: \(success), responses: Array of Result<TimeInterval, Error>"
    }
}

extension PingResult: Equatable {
    public static func == (lhs: PingResult, rhs: PingResult) -> Bool {
        lhs.host == rhs.host && lhs.count == rhs.count && lhs.average == rhs.average && lhs.success == rhs.success
    }
}

extension PingResult: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(host)
        hasher.combine(count)
        hasher.combine(average)
        hasher.combine(success)
    }
}
