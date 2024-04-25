//
//  SimplePingPingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

class SimplePingPingManager: PingManager {

    private var requests = [UInt16: Date]()
    private var results = [UInt16: TimeInterval]()
    private var session: PingSession?
    private var responseHandler: PingResponseHandler?

    func ping(host: String, configuration: PingConfiguration, _ responseHandler: PingResponseHandler? = nil, _ resultHandler: PingResultHandler? = nil) {

        self.responseHandler = responseHandler
        self.pingCount = configuration.count
        let session = PingSession(host: host, pingInterval: configuration.interval)

        session.start { [weak self] response in
            guard let self else { return }
            self.handle(response)
        }
        self.session = session
    }

    private func handle(_ response: PingSessionResponse) {
        switch response {
        case .sent(_, let packet, _): requests.updateValue(Date(), forKey: packet)

        case .received(_, let packet, let host):
            guard let start = requests[packet] else { return }
            let elapsed = abs(start.timeIntervalSinceNow)
            results.updateValue(elapsed, forKey: packet)
            responseHandler?(.success(PingSuccess(host: host, time: elapsed)))
        case .failed(let error, _): responseHandler?(.failure(error))
        default: break
        }
    }
}
