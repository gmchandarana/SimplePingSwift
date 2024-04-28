//
//  PingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import Foundation

typealias PingResponseHandler = ((Result<TimeInterval, Error>) -> Void)
typealias PingResultHandler = ((PingResult) -> Void)

protocol PingManagerDelegate {
    func didStartPinging(host: String)
    func didFailToStartPinging(host: String, error: Error)
    func didReceiveResponse(from host: String, response: Result<TimeInterval, Error>)
    func didFinishPinging(host: String, result: PingResult)
}

protocol PingManager {
    var delegate: PingManagerDelegate? { get set }
    func ping(host: String, configuration: PingConfiguration)
}
