//
//  PingRequestStatusTests.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 22/05/2024.
//

import XCTest
@testable import SimplePingSwift

final class PingRequestStatusTests: XCTestCase {

    var requestStatus: PingRequestStatus!

    override func setUp() {
        requestStatus = PingRequestStatus.sent(.init())
    }

    override func tearDown() {
        requestStatus = nil
    }

    func testPingRequestStatusSendsNilResponseForSentCase() {
        XCTAssertNil(requestStatus.response())
    }
    
    func testPingRequstStatusSendsValidResponse() {
        var status1 = PingRequestStatus(request: .success(.distantFuture))
        status1 = .received(1)
        XCTAssertNotNil(status1.response())

        let status2 = PingRequestStatus(request: .failure(PingSessionError.timeout))
        XCTAssertNotNil(status2.response())
    }
}
