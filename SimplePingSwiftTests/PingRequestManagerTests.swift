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
        manager = PingRequestManager(maxRequests: count) { callBack in
            switch callBack {
            case .count: callBackCount += 1
            case .results: break
            }
        }

        for index in 0..<count {
            manager.handleSent(request: .success(.init()), for: UInt16(index))
        }

        XCTAssertEqual(count, callBackCount)
    }

    func testPingRequestManagerInvokesResultsCallBack() {
        let count = 4
        var didReceiveResult = false
        manager = PingRequestManager(maxRequests: count) { callBack in
            switch callBack {
            case .count: break
            case .results: didReceiveResult = true
            }
        }

        for index in 0..<count {
            manager.handleSent(request: .success(.init()), for: UInt16(index))
            manager.handleReceived(responseAt: .init(), for: UInt16(index))
        }
        XCTAssertTrue(didReceiveResult)
    }

    func testPingRequestManagerResult() {
        let count = 5
        var expectedResult: [UInt16: Result<TimeInterval, Error>]?

        manager = PingRequestManager(maxRequests: count) { callBack in
            switch callBack {
            case .count: break
            case .results(let results): expectedResult = results
            }
        }

        for index in 0..<count {
            let sendDate = Date(timeIntervalSince1970: 0)
            let receivedDate = Date(timeIntervalSince1970: 1.5)
            manager.handleSent(request: .success(sendDate), for: UInt16(index))
            manager.handleReceived(responseAt: receivedDate, for: UInt16(index))
        }

        XCTAssertNotNil(expectedResult)
        XCTAssertEqual(expectedResult!.count, count)
        for result in expectedResult!.values {
            switch result {
            case .success(let latency): XCTAssertEqual(latency, 1.5)
            case .failure: XCTFail("Expected success, received failure.")
            }
        }
    }
}
