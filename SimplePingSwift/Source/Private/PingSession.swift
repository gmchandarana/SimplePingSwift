//
//  PingSession.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import Foundation
import SimplePingSwift.Private

enum PingSessionResponse {
    case didStartPinging(host: String)
    case didFailToStartPinging(host: String, error: Error)

    case didSendPacketTo(host: String)
    case didFailToSendPacketTo(host: String, error: Error)

    case didReceiveResponseFrom(host: String, response: Result<TimeInterval, Error>)
    case didFinishPinging(host: String, result: PingResult)
}

class PingSession: NSObject {

    let host: String
    let config: PingConfiguration
    var isActive: Bool { pinger != nil }

    private var pinger: SimplePing?
    private var handler: ((PingSessionResponse) -> Void)?
    private var requestManager: PingRequestManager
    private var timeoutTimers = ThreadSafeDictionary<UInt16, Timer?>()
    private let worker = BackgroundWorker()
    private weak var pingTimer: Timer?

    init(host: String, config: PingConfiguration = .default) {
        self.host = host
        self.config = config
        self.requestManager = PingRequestManager(maxCount: config.count)
    }

    func start(eventHandler: @escaping ((PingSessionResponse) -> Void)) {
        worker.start { [weak self] in
            guard let self else { return }
            handler = eventHandler
            pinger = SimplePing(hostName: host)
            pinger?.delegate = self
            pinger?.start()
        }
    }

    func stop() {
        stopAndNotifyResults()
    }

    private func setPingTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: config.interval, repeats: true) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            if requestManager.requests.count < config.count { pinger?.send(with: nil) }
        }
        pingTimer = timer
    }

    private func setTimeoutTimerForRequestWith(sequenceNumber: UInt16) {
        let timer = Timer.scheduledTimer(withTimeInterval: config.timeoutInterval, repeats: false) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            timeoutTimers[sequenceNumber]?.nullify()
            requestManager.handleReceived(response: .failure(PingSessionError.timeout), for: sequenceNumber)
            handler?(.didReceiveResponseFrom(host: host, response: .failure(PingSessionError.timeout)))
            if requestManager.hasReceivedAllResponses { stopAndNotifyResults() }
        }
        timeoutTimers.updateValue(timer, forKey: sequenceNumber)
    }

    private func stopAndNotifyResults() {
        pinger?.stop()
        pinger = nil
        worker.stop()
        invalidateTimers()
        let result = PingResult(host: host, responses: requestManager.results)
        handler?(.didFinishPinging(host: host, result: result))
    }

    private func invalidateTimers() {
        pingTimer.nullify()
        timeoutTimers.keys.forEach {
            timeoutTimers[$0]??.invalidate()
            timeoutTimers[$0] = nil
        }
    }
}

extension PingSession: SimplePingDelegate {

    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        setPingTimer()
        handler?(.didStartPinging(host: host))
    }

    func simplePing(_ pinger: SimplePing, didFailWithError error: any Error) {
        handler?(.didFailToStartPinging(host: host, error: PingSessionError.invalidHost))
    }

    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        requestManager.handleSent(request: .success(Date()), for: sequenceNumber)
        setTimeoutTimerForRequestWith(sequenceNumber: sequenceNumber)
        handler?(.didSendPacketTo(host: host))
    }

    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: any Error) {
        requestManager.handleSent(request: .failure(error), for: sequenceNumber)
        handler?(.didFailToSendPacketTo(host: host, error: error))
    }

    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        timeoutTimers[sequenceNumber]?.nullify()
        if let elapsed = requestManager.handleReceived(response: .success(Date()), for: sequenceNumber) {
            handler?(.didReceiveResponseFrom(host: host, response: .success(elapsed)))
        }
        if requestManager.hasReceivedAllResponses { stopAndNotifyResults() }
    }
}
