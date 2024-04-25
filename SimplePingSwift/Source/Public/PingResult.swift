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
    let responses: [PingSuccess]
}
