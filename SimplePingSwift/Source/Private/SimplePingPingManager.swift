//
//  SimplePingPingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

class SimplePingPingManager: PingManager {

    private var pingCount = Int()
    private var requests = [UInt16: Date]()
    private var results = [UInt16: Result<TimeInterval, Error>]()
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
        case .didStartPinging: break
        case .didSendPacketTo(let host, let sequenceNumber):
            updateRequestTimestampForPacket(from: host, with: sequenceNumber)
        case .didFailToSendPacketTo(let host, let sequenceNumber, let error):
            handleFailedToSendPacket(from: host, with: sequenceNumber, error: error)
        case .didReceivePacketFrom(let host, let sequenceNumber):
            handleReceivedPacket(from: host, with: sequenceNumber)
        case .didReceiveUnexpectedPacketFrom: break
        case .didFailToStartPinging(_, let error):
            responseHandler?(.failure(error))
        }
    }

    private func updateRequestTimestampForPacket(from host: String, with sequenceNumber: UInt16) {
        requests.updateValue(Date(), forKey: sequenceNumber)
    }

    private func handleReceivedPacket(from host: String, with sequenceNumber: UInt16) {
        guard let requestedTime = requests[sequenceNumber] else { return }
        let elapsed = abs(requestedTime.timeIntervalSinceNow)
        results.updateValue(.success(elapsed), forKey: sequenceNumber)
        let success = PingSuccess(host: host, time: elapsed)
        responseHandler?(.success(success))
        if results.count == pingCount {
            session?.stop()
        }
    }

    private func handleFailedToSendPacket(from host: String, with sequenceNumber: UInt16, error: Error) {
        guard requests[sequenceNumber] != nil else { return }
        results.updateValue(.failure(error), forKey: sequenceNumber)
        responseHandler?(.failure(error))
    }
}
