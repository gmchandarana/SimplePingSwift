//
//  PingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import Foundation

/// Protocol defining the main interface for starting ping operations.
public protocol PingManager {

    /// The delegate object that receives ping events. This should be set to an object that conforms to the `PingManagerDelegate` protocol.
    var delegate: PingManagerDelegate? { get set }

    /// Starts a ping operation for a single host.
    /// - Parameter host: The `Host` object representing the hostname or IP address to be pinged.
    func ping(host: Host)

    /// Starts ping operations for a set of hosts.
    /// - Parameter hosts: A set of `Host` objects representing the hostnames or IP addresses to be pinged.
    func ping(hosts: Set<Host>)
}
