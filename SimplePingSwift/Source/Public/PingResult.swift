//
//  PingResult.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

struct PingResult {
    let host: String
    let count: Int
    let average: Double
    let success: Double
    let responses: [Result<TimeInterval, Error>]
}

extension PingResult: CustomStringConvertible {
    var description: String {
        "PingResult(host: \(host), count: \(count), average: \(average), success: \(success), responses: Array of Result<TimeInterval, Error>"
    }
}
