//
//  SimplePingAccessTests.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 18/04/2024.
//

import XCTest
import SimplePingSwift.Private

final class SimplePingAccessTests: XCTestCase {

    func testCanAccessSimplePing() {
        let simplePing = SimplePing(hostName: "google.com")
        XCTAssertNotNil(simplePing, "Failed to instantiate SimplePing")
    }
}
