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

        let expectation = XCTestExpectation(description: "Session should start")
        session.start { [weak self] response in
            guard let self else { return }
            switch response {
            case .didStartPinging(let host, _):
                XCTAssertEqual(host, self.host)
                expectation.fulfill()
            default: break
            }
        }
        wait(for: [expectation], timeout: 5)
    }

    func testSessionFailsToStartWhenHostIsInvalid() {
        session = PingSession(host: invalidHost)

        let expectation = XCTestExpectation(description: "Session should not start")
        session.start { [weak self] response in
            guard let self else { return }
            switch response {
            case .didStartPinging:
                XCTFail("Expected failure, but received success")
            case .didFailToStartPinging(let host, _):
                XCTAssertEqual(host, self.invalidHost)
                expectation.fulfill()
            default: break
            }
        }
        wait(for: [expectation], timeout: 5)
    }

    func testSessionStaysActiveUntilTerminated() {
        let expectation = XCTestExpectation(description: "Session should stay active until stopped after 30 seconds")
        session.start { [weak self] response in
            guard let self else { return }
            switch response {
            case .didStartPinging(let host, _):
                XCTAssertEqual(host, self.host)
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    self.session.stop()
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

        wait(for: [expectation], timeout: 5)
    }

    func testZeroTimeInterval() {
        let session = PingSession(host: "facebook.com", pingInterval: 0)
        let expectation = XCTestExpectation(description: "Ping flood succeed")

        session.start { response in
            switch response {
            case .didStartPinging:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard let self else { return }
                    self.session.stop()
                    expectation.fulfill()
                }
            case .didFailToStartPinging: expectation.fulfill()
            default: break
            }
        }

        wait(for: [expectation], timeout: 2)
    }

    func testActiveStatus() {
        let expectation = XCTestExpectation(description: "PingSession's isActive flag should be true when session is running.")
        XCTAssertFalse(session.isActive)

        session.start { [weak self] response in
            guard let self else { return }
            switch response {
            case .didStartPinging: 
                XCTAssertTrue(self.session.isActive)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.session.stop()
                    XCTAssertFalse(self.session.isActive)
                    expectation.fulfill()
                }
            default: break
            }
        }

        wait(for: [expectation], timeout: 3)
    }
}
