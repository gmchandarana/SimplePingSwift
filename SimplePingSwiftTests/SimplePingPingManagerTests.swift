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
}
