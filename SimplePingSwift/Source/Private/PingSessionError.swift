//
//  PingSessionError.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 08/05/2024.
//

import Foundation

public enum PingSessionError: LocalizedError, Equatable {
    case invalidHost
    case timeout
}
