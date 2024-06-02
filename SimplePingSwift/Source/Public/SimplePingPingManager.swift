//
//  SimplePingPingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

public class SimplePingPingManager: PingManager {
    private var _sessions: [String: PingSession] = [:]
    private var sessions: [String: PingSession] {
        get {
            serialQueue.sync { _sessions }
        }
        set {
            serialQueue.async { [weak self] in self?._sessions = newValue }
        }
    }

    public var delegate: (any PingManagerDelegate)?
    private let serialQueue = DispatchQueue(label: "com.simpleping.queue")

    public init(delegate: PingManagerDelegate? = nil) {
        self.delegate = delegate
    }

    public func ping(host: Host) {
        let session = PingSession(host: host.name, config: host.config)
        sessions[host.name] = session
        session.start { [weak self] response in
            guard let self else { return }
            handle(response)
        }
    }

    public func ping(hosts: Set<Host>) {
        for host in hosts {
            ping(host: host)
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
            sessions.removeValue(forKey: host)
        }
    }
}
