//
//  PingConfiguration.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

/// Represents the configuration settings for a ping operation.
public struct PingConfiguration: Equatable, Hashable {
    /// The number of ping attempts.
    public let count: Int

    /// The interval between ping attempts in seconds.
    public let interval: TimeInterval

    /// The timeout interval for each ping attempt in seconds.
    public let timeoutInterval: TimeInterval

    /// Initializes a new `PingConfiguration` with the specified settings.
    /// - Parameters:
    ///   - count: The number of ping attempts. Defaults to 5.
    ///   - interval: The interval between ping attempts in seconds. Defaults to 0.5 seconds.
    ///   - timeoutInterval: The timeout interval for each ping attempt in seconds. Defaults to 1 second.
    ///
    ///   /// ⚠️ Warning: Exercise caution and ensure proper handling to prevent misuse and potential legal liabilities when pinging with very low frequency.
    public init(count: Int = 5, interval: TimeInterval = 0.5, timeoutInterval: TimeInterval = 1) {
        self.count = count
        self.interval = interval
        self.timeoutInterval = timeoutInterval
    }

    /// The default ping configuration.
       /// - Parameters:
       ///   - count: 5 ping attempts.
       ///   - interval: 0.5 seconds between attempts.
       ///   - timeoutInterval: 1 second timeout for each attempt.
    public static let `default` = PingConfiguration(count: 5, interval: 0.5, timeoutInterval: 1)
}
