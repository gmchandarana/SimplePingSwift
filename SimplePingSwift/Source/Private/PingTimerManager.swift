//
//  PingTimerManager.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 11/07/2024.
//

import Foundation

final class PingTimerManager {
    private weak var pingTimer: Timer?
    private var timeoutTimers = ThreadSafeDictionary<UInt16, Timer>()

    func startPingTimer(interval: TimeInterval, action: @escaping () -> Void) {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            action()
        }
        pingTimer = timer
    }

    func stopPingTimer() {
        pingTimer.nullify()
    }

    func startTimeoutTimer(sequenceNumber: UInt16, interval: TimeInterval, action: @escaping () -> Void) {
        let newTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            action()
        }
        timeoutTimers.updateValue(newTimer, forKey: sequenceNumber)
    }

    func stopTimeoutTimerFor(sequenceNumber: UInt16) {
        timeoutTimers[sequenceNumber].nullify()
    }

    func stopAllTimers() {
        pingTimer.nullify()
        timeoutTimers = ThreadSafeDictionary<UInt16, Timer>()
    }
}
