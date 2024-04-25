//
//  PingSession.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import Foundation
import SimplePingSwift.Private

enum PingSessionResponse {
    case started(_ host: String, address: Data)
    case sent(_ packet: Data, _ sequenceNumber: UInt16, _ host: String)
    case received(_ packet: Data, _ sequenceNumber: UInt16, _ host: String)
    case receivedUnexpected(_ packet: Data)
    case failed(_ error: Error,  _ host: String)
}

class PingSession: NSObject {

    let host: String
    private let pingInterval: TimeInterval
    private var pinger: SimplePing?
    private var handler: ((PingSessionResponse) -> Void)?
    private weak var timer: Timer?

    var isActive: Bool {
        pinger != nil
    }

    init(host: String, pingInterval: TimeInterval = 0.5) {
        self.pingInterval = pingInterval
        self.host = host
        super.init()
    }

    func start(handler: @escaping ((PingSessionResponse) -> Void)) {
        self.handler = handler
        if pinger == nil {
            initializePinger()
        }
        pinger?.start()
    }

    func stop() {
        pinger?.stop()
        pinger = nil
        handler = nil
        timer?.invalidate()
        timer = nil
    }

    private func initializePinger() {
        pinger = SimplePing(hostName: host)
        pinger?.delegate = self
    }

    private func startPinging() {
        timer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true) { [weak self] timer in
            guard let self else { return timer.invalidate() }
            self.pinger?.send(with: nil)
        }
    }
}

extension PingSession: SimplePingDelegate {

    func simplePing(_ pinger: SimplePing, didStartWithAddress address: Data) {
        startPinging()
        handler?(.started(host, address: address))
    }

    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        handler?(.sent(packet, sequenceNumber, host))
    }

    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        handler?(.received(packet, sequenceNumber, host))
    }

    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        handler?(.failed(error, host))
        stop()
    }

    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        handler?(.receivedUnexpected(packet))
    }
}
