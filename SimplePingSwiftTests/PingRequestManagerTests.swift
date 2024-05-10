//
//  PingRequestManagerTests.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 10/05/2024.
//

import XCTest
@testable import SimplePingSwift

final class PingRequestManagerTests: XCTestCase {

    var manager: PingRequestManager!

    func testPingRequestManagerInvokesConutCallBacksForEachRequest() {
        let count = 4
        var callBackCount = 0
        manager = PingRequestManager { _ in
            callBackCount += 1
        }

        for index in 0..<count {
            manager.handleSent(request: .success(.init()), for: UInt16(index))
        }

        XCTAssertEqual(count, callBackCount)
    }

    func testPingRequestManagerResult() {
        let count = 5
        manager = PingRequestManager { _ in }

        for index in 0..<count {
            let sendDate = Date(timeIntervalSince1970: 0)
            let receivedDate = Date(timeIntervalSince1970: 1.5)
            manager.handleSent(request: .success(sendDate), for: UInt16(index))
            manager.handleReceived(responseAt: receivedDate, for: UInt16(index))
        }
        let expectedResult = manager.results

        XCTAssertFalse(expectedResult.isEmpty)
        XCTAssertEqual(expectedResult.count, count)
        expectedResult.values.forEach { result in
            switch result {
            case .success(let latency): XCTAssertEqual(latency, 1.5)
            case .failure: XCTFail("Expected success, received failure.")
            }
        }
    }
}
