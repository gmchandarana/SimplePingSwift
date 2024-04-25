//
//  SimplePingPingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

public class SimplePingPingManager: PingManager {

    private var requests = [UInt16: Date]()
    private var results = [UInt16: TimeInterval]()
    private var session: PingSession?

    func ping(host: String, configuration: PingConfiguration, _ responseHandler: PingResponseHandler? = nil, _ resultHandler: PingResultHandler? = nil) {
        
        let session = PingSession(host: host, pingInterval: configuration.interval)

        session.start { [weak self] response in

            guard let self else { return }
            switch response {
            case .sent(_, let packet, _):
                self.requests.updateValue(Date(), forKey: packet)
            case .received(_, let packet, let host):
                guard let start = requests[packet] else { return }
                let elapsed = abs(start.timeIntervalSinceNow)
                self.results.updateValue(elapsed, forKey: packet)
                responseHandler?(.success(PingSuccess(host: host, time: elapsed)))
            default: break
            }
        }
        self.session = session
    }
}
