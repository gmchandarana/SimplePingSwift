//
//  SimplePingPingManagerTests.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import XCTest
@testable import SimplePingSwift

final class SimplePingPingManagerTests: XCTestCase {

    var manager: PingManager!
    let host = "example.com"
    let invalidHost = "xa0com"

    override func setUp() {
        super.setUp()
        manager = SimplePingPingManager()
    }

    override func tearDown() {
        manager = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(manager)
    }

    func testPingManagerStartsPingingHost() {
        let expectation = XCTestExpectation(description: "The pingManager starts pinging \(host)")

        var delegate = MockPingManagerDelegate()
        delegate.didStartPingingExpectation = expectation
        manager.delegate = delegate
        manager.ping(host: host, configuration: .default)

        wait(for: [expectation], timeout: 1)
    }

    func testPingManagerPingSuccess() {
        let count = 5
        let expectation = XCTestExpectation(description: "The pingManager should send \(count) responses.")
        expectation.expectedFulfillmentCount = count

        var delegate = MockPingManagerDelegate()
        delegate.didReceiveResponseExpectation = expectation
        manager.delegate = delegate
        manager.ping(host: host, configuration: PingConfiguration(count: count))

        wait(for: [expectation], timeout: 5)
    }

    func testPingManagerPingFailureForInvalidHost() {
        let expectation = XCTestExpectation(description: "The pingManager should fail.")

        var delegate = MockPingManagerDelegate()
        delegate.didFailToStartPingingExpectation = expectation
        manager.delegate = delegate
        manager.ping(host: invalidHost, configuration: .default)

        wait(for: [expectation], timeout: 5)
    }

    func testPingManagerSendsValidResult() {
        let expectation = XCTestExpectation(description: "After a specified number of ping requests, the ping manager should return a valid result.")

        let pingCount = 8
        let config = PingConfiguration(count: pingCount)
        var delegate = MockPingManagerDelegate()
        delegate.didReceiveResultExpectation = expectation
        delegate.expectedPingCount = pingCount
        manager.delegate = delegate
        manager.ping(host: host, configuration: config)
        wait(for: [expectation], timeout: 5)
    }
}

private struct MockPingManagerDelegate: PingManagerDelegate {

    var didStartPingingExpectation: XCTestExpectation?
    var didFailToStartPingingExpectation: XCTestExpectation?
    var didReceiveResponseExpectation: XCTestExpectation?
    var didReceiveResultExpectation: XCTestExpectation?
    var expectedPingCount: Int?

    func didStartPinging(host: String) {
        didStartPingingExpectation?.fulfill()
    }

    func didFailToStartPinging(host: String, error: Error) {
        didFailToStartPingingExpectation?.fulfill()
    }

    func didReceiveResponseFrom(host: String, response: Result<TimeInterval, any Error>) {
        didReceiveResponseExpectation?.fulfill()
    }

    func didFinishPinging(host: String, result: PingResult) {
        if let expectedPingCount {
            XCTAssertEqual(expectedPingCount, result.count)
        }
        
        didReceiveResultExpectation?.fulfill()
    }
}
