//
//  PingSessionTests.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import XCTest
@testable import SimplePingSwift

final class PingSessionTests: XCTestCase {

    let host = "example.com"
    let invalidHost = "xa0com"

    func testCanStartSessionWhenHostIsValid() {
        let session = makeSUT()
        let expectation = XCTestExpectation(description: "Session should start pinging to a valid host.")
        
        session.start { [weak self] response in
            guard let self else { return }
            switch response {
            case .didStartPinging(let host):
                XCTAssertEqual(host, self.host)
                expectation.fulfill()
            default: break
            }
        }
        wait(for: [expectation], timeout: 2)
    }

    func testSessionFailsToStartWhenHostIsInvalid() {
        let session = makeSUT(host: invalidHost)
        let expectation = XCTestExpectation(description: "Session should not start pinging to an invalid host.")
        session.start { [weak self] response in
            guard let self else { return }
            switch response {
            case .didStartPinging: XCTFail("Expected failure, but received success")
            case .didFailToStartPinging(let host, _):
                XCTAssertEqual(host, self.invalidHost)
                expectation.fulfill()
            default: break
            }
        }
        wait(for: [expectation], timeout: 5)
    }

    func testSessionSendsSpecifiedNumberOfRequests() {
        let count = 7
        let session = makeSUT(config: .init(count: count))
        let expectation = XCTestExpectation(description: "Should receive exactly \(count) responses.")
        expectation.expectedFulfillmentCount = count

        session.start { handler in
            switch handler {
            case .didSendPacketTo, .didFailToSendPacketTo: expectation.fulfill()
            default: break
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testSessionStopsSendingRequestsAfterSpecifiedNumberOfRequests() {
        let count = 8
        let expectation = XCTestExpectation(description: "Session should stop after \(count) requests.")
        let session = makeSUT(config: .init(count: count))

        session.start { response in
            switch response {
            case .didFinishPinging(let host, let result):
                XCTAssertEqual(host, self.host)
                XCTAssertEqual(result.responses.count, count)
                expectation.fulfill()
            default: break
            }
        }
        wait(for: [expectation], timeout: 10)
    }

    func testPingSessionRequestsTimeoutForUnknowLocalIP() {
        let count = 4
        let host = "127.0.0.0"
        let expectation = XCTestExpectation(description: "PingSession requests should time out when pinging unknown local IP.")
        let session = makeSUT(host: host, config: .init(count: count))
        session.start { response in
            switch response {
            case .didFinishPinging(_, let result):
                let timedOut = result.responses.contains(where: { arg0 in
                    if case .failure(let error) = arg0 {
                        error as! PingSessionError == PingSessionError.timeout
                    } else {
                        false
                    }
                })
                XCTAssertTrue(timedOut)
                expectation.fulfill()
            default: break
            }
        }

        wait(for: [expectation], timeout: 10)
    }

    func testSessionStaysActiveUntilTerminated() {
        let expectation = XCTestExpectation(description: "Session should stay active until stopped after 5 seconds.")

        let config = PingConfiguration(count: 100, interval: 1, timeoutInterval: 1)
        let session = PingSession(host: host, config: config)
        session.start { [weak self] response in
            guard let self else { return }
            switch response {
            case .didStartPinging(let host):
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    XCTAssertEqual(self.host, host)
                    XCTAssertTrue(session.isActive)
                    expectation.fulfill()
                }
            default: break
            }
        }

        wait(for: [expectation], timeout: 2)
    }

    func testEmptyHostInitialization() {
        let session = makeSUT(host: "")
        let expectation = XCTestExpectation(description: "Session should fail")

        session.start { response in
            switch response {
            case .didFailToStartPinging: expectation.fulfill()
            default: break
            }
        }

        wait(for: [expectation], timeout: 1)
    }

    func testPingSessionCanStop() {
        let pingCount = 20
        let stoppingAtCount = pingCount - Int.random(in: 0..<pingCount)

        let expectation = XCTestExpectation(description: "Ping Session stops pinging after \(stoppingAtCount) requests, and results should reflect the same count.")

        let config = PingConfiguration(count: pingCount, interval: 0.1)
        let session = PingSession(host: host, config: config)

        var currentCount = 0

        session.start { response in
            switch response {
            case .didFinishPinging(_, let result):
                if result.count == stoppingAtCount {
                    expectation.fulfill()
                } else {
                    XCTFail("Expected the result.count to be equal to stoppingAtCount.")
                }
            case .didSendPacketTo:
                if currentCount == stoppingAtCount {
                    session.stop()
                } else {
                    currentCount += 1
                }
            default: break
            }
        }

        wait(for: [expectation], timeout: 2.5)
    }

    func testPingManagerRequestTimeOut() {
        let slowerHost = "yahoo.co.jp"
        let expectation = XCTestExpectation(description: "Some request should time out. This test depends on the host and speed of the network, so it is not reliable.")
        let session = makeSUT(host: slowerHost, config: .init(count: 50, interval: 0.1, timeoutInterval: 0.2))

        session.start { response in
            switch response {
            case .didStartPinging(let host): XCTAssertEqual(host, slowerHost)
            case .didReceiveResponseFrom(host: let host, response: _):
                XCTAssertEqual(host, slowerHost)
            case .didFinishPinging(host: _, result: let result):
                let timedOut = result.responses.contains(where: { arg0 in
                    if case .failure(let error) = arg0 {
                        error as! PingSessionError == PingSessionError.timeout
                    } else {
                        false
                    }
                })
                XCTAssertTrue(timedOut)
                expectation.fulfill()
            default: break
            }
        }
        wait(for: [expectation], timeout: 5.5)
    }
}

extension PingSessionTests {

    private func makeSUT(host: String = "example.com", config: PingConfiguration = .default) -> PingSession {
        let session = PingSession(host: host, config: config)
        trackMemoryLeaks(for: session)
        return session
    }

}
