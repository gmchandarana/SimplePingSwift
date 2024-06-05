//
//  PingResult.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

/// Represents the result of a ping operation.
public struct PingResult {
    /// The hostname or IP address that was pinged.
    public let host: String

    /// The total number of ping attempts.
    public let count: Int

    /// The average round-trip time of successful ping attempts.
    public let average: Double

    /// The success rate of the ping attempts as a fraction.
    public let success: Double

    /// An array of responses for each ping attempt, each being a `Result` containing either the round-trip time (`TimeInterval`) or an error (`Error`).
    public let responses: [Result<TimeInterval, Error>]
}

extension PingResult {

    /// Initializes a new `PingResult` with a given host and a dictionary of responses.
    /// - Parameters:
    ///   - host: The hostname or IP address that was pinged.
    ///   - responses: A dictionary of responses keyed by an identifier, where the values are `Result` objects containing either the round-trip time (`TimeInterval`) or an error (`Error`).
    public init(host: String, responses: [UInt16: Result<TimeInterval, Error>]) {
        self.host = host
        self.count = responses.count
        self.responses = responses.map { $0.value }

        let successfulResponses = self.responses.compactMap {
            if case let .success(timeInterval) = $0 { timeInterval } else { nil }
        }

        if successfulResponses.count > 0 {
            self.average = successfulResponses.reduce(0, +)/Double(successfulResponses.count)
        } else {
            self.average = 0
        }

        if count > 0 {
            self.success = Double(successfulResponses.count)/Double(count)
        } else {
            self.success = 0
        }
    }
}
/// Extension to conform `PingResult` to `CustomStringConvertible` for a descriptive output.
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
