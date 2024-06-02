//
//  PingConfigurationTests.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 09/05/2024.
//

import XCTest
@testable import SimplePingSwift

final class PingConfigurationTests: XCTestCase {

    var config: PingConfiguration?

    override func setUp() {
        config = PingConfiguration(count: 5, interval: 0.5, timeoutInterval: 1)
    }

    override func tearDown() {
        config = nil
    }

    func testCanInitialize() {
        XCTAssertNotNil(config)
    }

    func testDefaultInitialization() {
        let defaultConfig = PingConfiguration()
        XCTAssertEqual(defaultConfig.count, 5)
        XCTAssertEqual(defaultConfig.interval, 0.5)
        XCTAssertEqual(defaultConfig.timeoutInterval, 1)
    }

    func testCustomInitialization() {
        let customConfig = PingConfiguration(count: 10, interval: 1.0, timeoutInterval: 3.0)
        XCTAssertEqual(customConfig.count, 10)
        XCTAssertEqual(customConfig.interval, 1.0)
        XCTAssertEqual(customConfig.timeoutInterval, 3.0)
    }
}
