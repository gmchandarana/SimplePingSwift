//
//  PingConfiguration.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

struct PingConfiguration {
    let count: Int
    let interval: TimeInterval
    let timeoutInterval: TimeInterval

    static let `default` = PingConfiguration(count: 5, interval: 0.5, timeoutInterval: 2)
}
