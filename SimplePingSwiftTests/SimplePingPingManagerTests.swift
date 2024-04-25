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

    func testPingManagerPingSuccess() {
        let expectation = expectation(description: "The pingManager should succeed.")
        manager.ping(host: host, configuration: .default, { response in
            switch response {
            case .success: expectation.fulfill()
            case .failure: XCTFail("Expected success, but received failure")
            }
        }, nil)

        wait(for: [expectation], timeout: 5)
    }

    func testPingManagerPingFailureForInvalidHost() {
        let expectation = expectation(description: "The pingManager should fail.")
        manager.ping(host: invalidHost, configuration: .default, { response in
            switch response {
            case .success: XCTFail("Expected failure, but received success")
            case .failure: expectation.fulfill()
            }
        }, nil)

        wait(for: [expectation], timeout: 5)
    }

    func testPingManagerShouldStopAfterSendingSpecifiedNumberOfRequests() {
        let pingCount = 5
        let expectation = expectation(description: "The pingManager should stop after \(pingCount) requests.")

        var responseCount = 0
        let config = PingConfiguration(count: pingCount)

        manager.ping(host: host, configuration: config, { response in
            responseCount += 1
        }, nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if responseCount > pingCount {
                XCTFail("PingManager should've stopped after \(pingCount) requests.")
            } else {
                XCTAssertTrue(pingCount == responseCount)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 6)
    }
}
