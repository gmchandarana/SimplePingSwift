//
//  PingResult.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

public struct PingResult {
    let host: String
    let count: Int
    let average: Double
    let success: Double
    let responses: [Result<TimeInterval, Error>]
}

extension PingResult {

    init(host: String, count: Int, responses: [Result<TimeInterval, Error>]) {
        self.host = host
        self.count = responses.count
        self.responses = responses

        let successfulResponses = responses.compactMap {
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
