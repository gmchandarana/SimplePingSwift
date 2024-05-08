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
        pinger = SimplePing(hostName: host)
        requestManager = PingRequestManager(maxRequests: config.count, callBack: pingRequestManagerCallBackHandler)
        pinger?.delegate = self
        pinger?.start()
    }

    func stop() {
        handleTimeout()
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
        let timer = Timer.scheduledTimer(withTimeInterval:  totalTimeoutInterval, repeats: false) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            handleTimeout()
        }
        timeoutTimer = timer
    }

    private func pingRequestManagerCallBackHandler(_ callBack: PingRequestManagerCallBackType) {
        if case .count(let count) = callBack {
            if count == 1 {
                setTimeoutTimer()
            } else if count == config.count {
                pingTimer.nullify()
            }
        } else if case .results(let dictionary) = callBack {
            let result = PingResult(host: host, count: config.count, responses: dictionary.map { $0.value })
            handler?(.didFinishPinging(host: host, result: result))
        }
    }

    private func handleTimeout() {
        pinger?.stop()
        pinger = nil
        pingTimer.nullify()
        timeoutTimer.nullify()
        let result = PingResult(host: host, count: config.count, responses: requestManager.results.map { $0.value })
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
        requestManager.addSent(request: .success(Date()), for: sequenceNumber)
        handler?(.didSendPacketTo(host: host))
    }

    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: any Error) {
        requestManager.addSent(request: .failure(error), for: sequenceNumber)
        handler?(.didFailToSendPacketTo(host: host, error: error))
    }

    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        guard let elapsed = requestManager.handleReceivedResponse(at: Date(), for: sequenceNumber) else { return }
        handler?(.didReceiveResponseFrom(host: host, response: .success(elapsed)))
    }
}
