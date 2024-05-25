//
//  Host.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/05/2024.
//

import Foundation

public struct Host: Hashable {

    let name: String
    let config: PingConfiguration

    init(name: String, config: PingConfiguration = .default) {
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
