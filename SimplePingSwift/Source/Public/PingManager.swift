//
//  PingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import Foundation

typealias PingResponseHandler = ((Result<TimeInterval, Error>) -> Void)
typealias PingResultHandler = ((PingResult) -> Void)

protocol PingManager {

    func ping(
        host: String,
        configuration: PingConfiguration,
        _ responseHandler: PingResponseHandler?,
        _ resultHandler: PingResultHandler?
    )
}
