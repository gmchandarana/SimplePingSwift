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

    func testPingManagerRequestsTimeoutForUnknowLocalIP() {
        let host = "127.0.0.0"
        let expectation = XCTestExpectation(description: "PingManager requests should time out when pinging unknown local IP.")
        var delegate = MockPingManagerDelegate()
        delegate.expectingTimeoutResult = true
        delegate.didReceiveTimeoutResultExpectation = expectation
        manager.delegate = delegate
        manager.ping(host: host, configuration: .init(count: 1, timeoutInterval: 2))
        wait(for: [expectation], timeout: 5)
    }

    func testCanPingMultipleHosts() {
        let expectation = XCTestExpectation(description: "PingManager can ping multiple hosts.")
        let hosts = ["google.com", "facebook.com", "yahoo.co.jp", "node.org", "amazon.in", "x.com"]
        expectation.expectedFulfillmentCount = hosts.count

        var delegate = MockPingManagerDelegate()
        delegate.didReceiveResultExpectation = expectation

        manager.delegate = delegate
        manager.ping(hosts: hosts)
        wait(for: [expectation], timeout: 5)
    }

    func testMultipleInvalidHosts() {
        let expectation = XCTestExpectation(description: "PingManager fails to ping an invalid host.")
        let hosts = ["g124oogle.com", "faceboo)19k.com", "yah_oo1..co.jp", "ndone12ode.org", "amazon.co.uk.in", "x.com.in.co.jp"]
        expectation.expectedFulfillmentCount = hosts.count

        var delegate = MockPingManagerDelegate()
        delegate.didFailToStartPingingExpectation = expectation

        manager.delegate = delegate
        manager.ping(hosts: hosts)
        wait(for: [expectation], timeout: 5)
    }

    func testMixHosts() {
        let invalidExpectation = XCTestExpectation(description: "PingManager fails to ping an invalid host.")
        let validExpectation = XCTestExpectation(description: "PingManager pings a valid host.")

        let validHosts = ["google.com", "facebook.com"]
        let invalidHosts = ["yah_oo1..co.jp", "ndone12ode.org", "amazon.co.uk.in", "x.com.in.co.jp"]

        let resultExpectation = XCTestExpectation(description: "PingManager should send a result.")
        resultExpectation.expectedFulfillmentCount = validHosts.count

        validExpectation.expectedFulfillmentCount = validHosts.count
        invalidExpectation.expectedFulfillmentCount = invalidHosts.count

        var delegate = MockPingManagerDelegate()
        delegate.didStartPingingExpectation = validExpectation
        delegate.didFailToStartPingingExpectation = invalidExpectation
        delegate.didReceiveResultExpectation = resultExpectation
        delegate.expectedPingCount = 5 // Default config


        manager.delegate = delegate
        manager.ping(hosts: validHosts + invalidHosts)
        wait(for: [validExpectation, invalidExpectation, resultExpectation], timeout: 10)
    }
}

private struct MockPingManagerDelegate: PingManagerDelegate {

    var didStartPingingExpectation: XCTestExpectation?
    var didFailToStartPingingExpectation: XCTestExpectation?
    var didReceiveResponseExpectation: XCTestExpectation?
    var didReceiveResultExpectation: XCTestExpectation?
    var didReceiveErroredResponseExpectation: XCTestExpectation?
    var didReceiveTimeoutResultExpectation: XCTestExpectation?

    var expectedPingCount: Int?
    var expectingErroredResponse: Bool?
    var expectingTimeoutResult: Bool?

    func didStartPinging(host: String) {
        didStartPingingExpectation?.fulfill()
    }

    func didFailToStartPinging(host: String, error: Error) {
        didFailToStartPingingExpectation?.fulfill()
    }

    func didReceiveResponseFrom(host: String, response: Result<TimeInterval, any Error>) {
        guard expectingErroredResponse == true else {
            didReceiveResponseExpectation?.fulfill()
            return
        }

        switch response {
        case .success: XCTFail("Expected failure, but received success.")
        case .failure: didReceiveErroredResponseExpectation?.fulfill()
        }
    }

    func didFinishPinging(host: String, result: PingResult) {
        if let expectedPingCount {
            XCTAssertEqual(expectedPingCount, result.count)
            print("Got the result - ", result)
        }

        if expectingTimeoutResult == true {
            let timeoutRequest = result.responses.contains(where: { response in
                if case .failure(let failure) = response {
                    return PingSessionError.timeout == failure as! PingSessionError
                } else {
                    return false
                }
            })
            XCTAssertTrue(timeoutRequest)
            didReceiveTimeoutResultExpectation?.fulfill()
        }

        didReceiveResultExpectation?.fulfill()
    }
}
