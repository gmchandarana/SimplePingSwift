//
//  SimplePingPingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

public class SimplePingPingManager: PingManager {

    private var session: PingSession?
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
        self.session = session
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
