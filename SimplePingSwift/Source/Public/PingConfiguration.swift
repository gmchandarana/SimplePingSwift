//
//  PingConfiguration.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

public struct PingConfiguration: Equatable, Hashable {
    let count: Int
    let interval: TimeInterval
    let timeoutInterval: TimeInterval

    public init(count: Int = 5, interval: TimeInterval = 0.5, timeoutInterval: TimeInterval = 2) {
        precondition(interval >= 0.1)
        precondition(timeoutInterval >= 0.5)

        self.count = count
        self.interval = interval
        self.timeoutInterval = timeoutInterval
    }

    public static let `default` = PingConfiguration(count: 5, interval: 0.5, timeoutInterval: 2)
}
