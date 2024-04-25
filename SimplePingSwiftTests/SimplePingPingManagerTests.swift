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
}
