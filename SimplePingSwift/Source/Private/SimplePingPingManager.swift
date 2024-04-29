//
//  SimplePingPingManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import Foundation

public class SimplePingPingManager: PingManager {

    private var pingCount = Int()
    private var requests = [UInt16: Date]()
    private var results = [UInt16: Result<TimeInterval, Error>]()
    private var session: PingSession?
    public var delegate: (any PingManagerDelegate)?

    init(delegate: PingManagerDelegate? = nil) {
        self.delegate = delegate
    }

    public func ping(host: String, configuration: PingConfiguration) {
        pingCount = configuration.count
        let session = PingSession(host: host, pingInterval: configuration.interval)
        session.start { [weak self] response in
            guard let self else { return }
            self.handle(response)
        }
        self.session = session
    }

    private func handle(_ response: PingSessionResponse) {
        switch response {
        case .didStartPinging(let host, _):
            delegate?.didStartPinging(host: host)
        case .didSendPacketTo(let host, let sequenceNumber):
            updateRequestTimestampForPacketFrom(host: host, sequenceNumber: sequenceNumber)
        case .didFailToSendPacketTo(let host, let sequenceNumber, let error):
            handleFailedToSendPacketTo(host: host, sequenceNumber: sequenceNumber, error: error)
        case .didReceivePacketFrom(let host, let sequenceNumber):
            handleReceivedPacketFrom(host: host, sequenceNumber: sequenceNumber)
        case .didReceiveUnexpectedPacketFrom: break
        case .didFailToStartPinging(let host, let error):
            delegate?.didFailToStartPinging(host: host, error: error)
        }
    }

    private func updateRequestTimestampForPacketFrom(host: String, sequenceNumber: UInt16) {
        requests.updateValue(Date(), forKey: sequenceNumber)
    }

    private func handleReceivedPacketFrom(host: String, sequenceNumber: UInt16) {
        guard let requestedTime = requests[sequenceNumber] else { return }
        let elapsed = abs(requestedTime.timeIntervalSinceNow)
        results.updateValue(.success(elapsed), forKey: sequenceNumber)
        delegate?.didReceiveResponseFrom(host: host, response: .success(elapsed))

        if results.count == pingCount {
            session?.stop()
            let successes = results.values.compactMap { if case .success(let latency) = $0 { latency } else { nil } }
            let success = Double(successes.count)/Double(pingCount)
            let average = successes.reduce(0, +)/Double(pingCount)

            let result = PingResult(host: host, count: pingCount, average: average, success: success, responses: results.values.map { $0 })
            delegate?.didFinishPinging(host: host, result: result)
        }
    }

    private func handleFailedToSendPacketTo(host: String, sequenceNumber: UInt16, error: Error) {
        guard requests[sequenceNumber] != nil else { return }
        results.updateValue(.failure(error), forKey: sequenceNumber)
        delegate?.didReceiveResponseFrom(host: host, response: .failure(error))
    }
}
