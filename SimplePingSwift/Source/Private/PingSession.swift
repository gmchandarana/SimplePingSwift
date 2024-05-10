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
    private weak var pingTimer: Timer?
    private weak var timeoutTimer: Timer?

    private var requestManager: PingRequestManager!

    init(host: String, config: PingConfiguration = .default) {
        self.host = host
        self.config = config
    }

    func start(eventHandler: @escaping ((PingSessionResponse) -> Void)) {
        handler = eventHandler
        requestManager = PingRequestManager(requestCountHandler: pingRequestManagerRequestCountHandler(_:))
        pinger = SimplePing(hostName: host)
        pinger?.delegate = self
        pinger?.start()
    }

    func stop() {
        stopAndNotifyResults()
    }

    private func setPingTimer() {
        let timer = Timer.scheduledTimer(withTimeInterval: config.interval, repeats: true) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            self.pinger?.send(with: nil)
        }
        pingTimer = timer
    }

    private func setTimeoutTimer() {
        let totalTimeoutInterval = config.timeoutInterval * Double(config.count)
        let totalSendingTime = config.interval * Double(config.count)
        let minRequiredTime = max(totalTimeoutInterval, totalSendingTime)
        
        let timer = Timer.scheduledTimer(withTimeInterval: minRequiredTime, repeats: false) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            stopAndNotifyResults(didTimeout: true)
        }
        timeoutTimer = timer
    }

    private func pingRequestManagerRequestCountHandler(_ count: Int) {
        if count == 1 {
            setTimeoutTimer()
        } else if count == config.count {
            pingTimer.nullify()
        }
    }

    private func stopAndNotifyResults(didTimeout: Bool = false) {
        pinger?.stop()
        pinger = nil
        pingTimer.nullify()
        timeoutTimer.nullify()
        if didTimeout { requestManager.updateResultsForTimeout() }
        let result = PingResult(host: host, responses: requestManager.results)
        handler?(.didFinishPinging(host: host, result: result))
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
        handler?(.didSendPacketTo(host: host))
    }

    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: any Error) {
        requestManager.handleSent(request: .failure(error), for: sequenceNumber)
        handler?(.didFailToSendPacketTo(host: host, error: error))
    }

    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let elapsed = requestManager.handleReceived(responseAt: Date(), for: sequenceNumber) else { return }
        handler?(.didReceiveResponseFrom(host: host, response: .success(elapsed)))
        if requestManager.results.count == config.count {
            stopAndNotifyResults()
        }
    }
}
