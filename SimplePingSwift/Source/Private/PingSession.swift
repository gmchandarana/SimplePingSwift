//
//  PingSession.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import Foundation
import SimplePingSwift.Private

enum PingSessionResponse {
    case didStartPinging(host: String, address: Data)
    case didSendPacketTo(host: String, sequenceNumber: UInt16)
    case didFailToSendPacketTo(host: String, sequenceNumber: UInt16, error: Error)
    case didReceivePacketFrom(host: String, sequenceNumber: UInt16)
    case didReceiveUnexpectedPacketFrom(host: String)
    case didFailToStartPinging(host: String, error: Error)
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
        timer?.invalidate()
        timer = nil
        pinger?.stop()
        pinger = nil
        handler = nil
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
        handler?(.didStartPinging(host: host, address: address))
    }

    func simplePing(_ pinger: SimplePing, didSendPacket packet: Data, sequenceNumber: UInt16) {
        handler?(.didSendPacketTo(host: host, sequenceNumber: sequenceNumber))
    }

    func simplePing(_ pinger: SimplePing, didFailToSendPacket packet: Data, sequenceNumber: UInt16, error: any Error) {
        handler?(.didFailToSendPacketTo(host: host, sequenceNumber: sequenceNumber, error: error))
    }

    func simplePing(_ pinger: SimplePing, didReceivePingResponsePacket packet: Data, sequenceNumber: UInt16) {
        handler?(.didReceivePacketFrom(host: host, sequenceNumber: sequenceNumber))
    }

    func simplePing(_ pinger: SimplePing, didFailWithError error: Error) {
        handler?(.didFailToStartPinging(host: host, error: error))
        stop()
    }

    func simplePing(_ pinger: SimplePing, didReceiveUnexpectedPacket packet: Data) {
        handler?(.didReceiveUnexpectedPacketFrom(host: host))
    }
}
