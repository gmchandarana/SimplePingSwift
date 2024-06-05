//
//  PingManagerDelegate.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 04/06/2024.
//

import Foundation

/// Protocol defining the delegate methods for PingManager.
public protocol PingManagerDelegate {

    /// Called when the ping operation starts for a given host.
    /// - Parameter host: The hostname or IP address being pinged.
    func didStartPinging(host: String)

    /// Called when the ping operation fails to start for a given host.
    /// - Parameters:
    ///   - host: The hostname or IP address that failed to start pinging.
    ///   - error: The error that caused the failure.
    func didFailToStartPinging(host: String, error: Error)

    /// Called when a response is received from a host.
    /// - Parameters:
    ///   - host: The hostname or IP address from which the response was received.
    ///   - response: The result of the ping operation, containing either the round-trip time (`TimeInterval`) or an error (`Error`).
    func didReceiveResponseFrom(host: String, response: Result<TimeInterval, Error>)

    /// Called when the ping operation finishes for a given host.
    /// - Parameters:
    ///   - host: The hostname or IP address that was pinged.
    ///   - result: The final result of the ping operation, encapsulated in a `PingResult` object.
    func didFinishPinging(host: String, result: PingResult)
}
