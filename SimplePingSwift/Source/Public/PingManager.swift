//
//  PingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import Foundation

public protocol PingManagerDelegate {
    func didStartPinging(host: String)
    func didFailToStartPinging(host: String, error: Error)
    func didReceiveResponseFrom(host: String, response: Result<TimeInterval, Error>)
    func didFinishPinging(host: String, result: PingResult)
}

public protocol PingManager {
    var delegate: PingManagerDelegate? { get set }
    func ping(host: String, configuration: PingConfiguration)
}
