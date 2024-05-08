//
//  PingSessionTests.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import XCTest
@testable import SimplePingSwift

final class PingSessionTests: XCTestCase {

    var session: PingSession!
    let host = "example.com"
    let invalidHost = "xa0com"

    override func setUp() {
        super.setUp()
        session = PingSession(host: host)
    }

    override func tearDown() {
        session = nil
        super.tearDown()
    }

    func testCanStartSessionWhenHostIsValid() {
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
        session = PingSession(host: invalidHost)

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
        let expectation = XCTestExpectation(description: "Should receive exactly \(count) responses.")
        expectation.expectedFulfillmentCount = count
        let session = PingSession(host: host, config: .init(count: count))
        
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
        let session = PingSession(host: host, config: .init(count: count))
        
        session.start { response in
            switch response {
            case .didFinishPinging(let host, let result):
                XCTAssertEqual(host, self.host)
                XCTAssertEqual(result.responses.count, count)
                expectation.fulfill()
            default: break
            }
        }
        wait(for: [expectation], timeout: 5)
    }

    func testPingSessionRequestsTimeoutForUnknowLocalIP() {
        let count = 4
        let host = "127.0.0.0"
        let expectation = XCTestExpectation(description: "PingSession requests should time out when pinging unknown local IP.")
        let session = PingSession(host: host, config: .init(count: count))
        session.start { response in
            switch response {
            case .didFinishPinging(_, let result):
                print(result)
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
        let expectation = XCTestExpectation(description: "Session should stay active until stopped after 15 seconds.")

        let config = PingConfiguration(count: 100, interval: 0.5, timeoutInterval: 1)
        let session = PingSession(host: host, config: config)
        session.start { [weak self] response in
            guard let self else { return }
            switch response {
            case .didStartPinging(let host):
                DispatchQueue.global().asyncAfter(deadline: .now() + 15) {
                    XCTAssertEqual(self.host, host)
                    XCTAssertTrue(session.isActive)
                    expectation.fulfill()
                }
            default: break
            }
        }

        wait(for: [expectation], timeout: 20) // 15 + 5 seconds buffer
    }

    func testEmptyHostInitialization() {
        let session = PingSession(host: "")
        let expectation = XCTestExpectation(description: "Session should fail")

        session.start { response in
            switch response {
            case .didFailToStartPinging: expectation.fulfill()
            default: break
            }
        }

        wait(for: [expectation], timeout: 1)
    }

//    func testZeroTimeInterval() {
//        let session = PingSession(host: "facebook.com")
//        let expectation = XCTestExpectation(description: "Ping flood succeed")
//
//        session.start { response in
//            switch response {
//            case .didStartPinging:
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//                    guard let self else { return }
//                    self.session.stop()
//                    expectation.fulfill()
//                }
//            case .didFailToStartPinging: expectation.fulfill()
//            default: break
//            }
//        }
//
//        wait(for: [expectation], timeout: 2)
//    }
}
