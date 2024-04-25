//
//  PingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import Foundation

typealias PingResultHandler = ((Result<Void, Error>) -> ())
typealias PingResponseHandler = ((Result<Void, Error>) -> ())
typealias PingConfiguration = ()

protocol PingManager {

    func ping(
        host: String,
        configuration: PingConfiguration,
        responseHandler: PingResponseHandler,
        resultHandler: PingResultHandler
    )
}
