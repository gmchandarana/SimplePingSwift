//
//  SimplePingPingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

public class SimplePingPingManager: PingManager {

    private var sessions: [String: PingSession] = [:]
    public var delegate: (any PingManagerDelegate)?

    init(delegate: PingManagerDelegate? = nil) {
        self.delegate = delegate
    }

    public func ping(host: String, configuration: PingConfiguration) {
        let session = PingSession(host: host, config: configuration)
        session.start { [weak self] response in
            guard let self else { return }
            self.handle(response)
        }
        self.sessions.updateValue(session, forKey: host)
    }

    public func ping(hosts: [String]) {
        for host in hosts {
            ping(host: host, configuration: .default)
        }
    }

    private func handle(_ response: PingSessionResponse) {
        switch response {
        case .didStartPinging(let host):
            delegate?.didStartPinging(host: host)
        case .didFailToStartPinging(let host, let error):
            delegate?.didFailToStartPinging(host: host, error: error)
        case .didSendPacketTo, .didFailToSendPacketTo: break
        case .didReceiveResponseFrom(let host, let response):
            delegate?.didReceiveResponseFrom(host: host, response: response)
        case .didFinishPinging(let host, let result):
            delegate?.didFinishPinging(host: host, result: result)
        }
    }
}
