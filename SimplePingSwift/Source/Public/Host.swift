//
//  Host.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/05/2024.
//

import Foundation

/// Represents a host to be pinged along with its configuration.
public struct Host: Hashable {

    public let name: String
    public let config: PingConfiguration

    /// Initializes a new host with a given name and configuration.
    /// - Parameters:
    ///   - name: The hostname or IP address to be pinged.
    ///   - config: The configuration for the ping operation.
    public init(name: String, config: PingConfiguration = .default) {
        self.name = name
        self.config = config
    }

    public static func == (lhs: Host, rhs: Host) -> Bool {
        lhs.name == rhs.name && lhs.config == rhs.config
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(config)
    }
}
