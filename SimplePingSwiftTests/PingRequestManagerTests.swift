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

    override func setUp() {
        manager = PingRequestManager(maxCount: 5)
    }

    func testInitialization() {
        XCTAssertEqual(manager.maxCount, 5)
        XCTAssertTrue(manager.requests.isEmpty)
        XCTAssertFalse(manager.hasReceivedAllResponses)
    }

    func testHandleSentRequest() {
        var manager = PingRequestManager(maxCount: 3)
        let date = Date()
        let result: Result<Date, Error> = .success(date)
        manager.handleSent(request: result, for: 1)

        XCTAssertEqual(manager.requests.count, 1)
        if case .sent(let requestDate) = manager.requests[1] {
            XCTAssertEqual(requestDate, date)
        } else {
            XCTFail("Expected .sent status with correct date")
        }
    }

    func testHandleReceivedResponseSuccess() {
        var manager = PingRequestManager(maxCount: 3)
        let sentDate = Date()
        manager.handleSent(request: .success(sentDate), for: 1)

        let receivedDate = sentDate.addingTimeInterval(1)
        let responseResult: Result<Date, Error> = .success(receivedDate)
        let elapsed = manager.handleReceived(response: responseResult, for: 1)!

        XCTAssertEqual(manager.requests.count, 1)
        XCTAssertEqual(elapsed, 1, accuracy: 0.001)
        if case .received(let timeInterval) = manager.requests[1] {
            XCTAssertEqual(timeInterval, 1, accuracy: 0.001)
        } else {
            XCTFail("Expected .received status with correct time interval")
        }
    }

    func testHandleReceivedResponseFailure() {
        var manager = PingRequestManager(maxCount: 3)
        let sentDate = Date()
        manager.handleSent(request: .success(sentDate), for: 1)

        let error = NSError(domain: "test", code: 1, userInfo: nil)
        let responseResult: Result<Date, Error> = .failure(error)
        let elapsed = manager.handleReceived(response: responseResult, for: 1)

        XCTAssertEqual(manager.requests.count, 1)
        XCTAssertNil(elapsed)
        if case .failed(let receivedError) = manager.requests[1] {
            XCTAssertEqual(receivedError as NSError, error)
        } else {
            XCTFail("Expected .failed status with correct error")
        }
    }

    func testHasReceivedAllResponses() {
        var manager = PingRequestManager(maxCount: 2)
        XCTAssertFalse(manager.hasReceivedAllResponses)

        manager.handleSent(request: .success(Date()), for: 1)
        manager.handleSent(request: .success(Date()), for: 2)
        XCTAssertFalse(manager.hasReceivedAllResponses)

        manager.handleReceived(response: .success(Date()), for: 1)
        XCTAssertFalse(manager.hasReceivedAllResponses)

        manager.handleReceived(response: .success(Date()), for: 2)
        XCTAssertTrue(manager.hasReceivedAllResponses)
    }

    func testResults() {
        var manager = PingRequestManager(maxCount: 2)
        let sentDate1 = Date()
        let sentDate2 = sentDate1.addingTimeInterval(1)

        manager.handleSent(request: .success(sentDate1), for: 1)
        manager.handleSent(request: .success(sentDate2), for: 2)

        let receivedDate1 = sentDate1.addingTimeInterval(2)
        manager.handleReceived(response: .success(receivedDate1), for: 1)

        let error = NSError(domain: "test", code: 1, userInfo: nil)
        manager.handleReceived(response: .failure(error), for: 2)

        let results = manager.results
        XCTAssertEqual(results.count, 2)
        if case .success(let timeInterval) = results[1] {
            XCTAssertEqual(timeInterval, 2, accuracy: 0.001)
        } else {
            XCTFail("Expected successful result with correct time interval")
        }
    }

    func testConcurrentAccess() {
        var manager = PingRequestManager(maxCount: 100)
        let concurrentQueue = DispatchQueue.global(qos: .background)
        let group = DispatchGroup()

        for index in 0..<100 {
            group.enter()
            concurrentQueue.async {
                let requestResult: Result<Date, Error> = .success(Date())
                manager.handleSent(request: requestResult, for: UInt16(index))
                group.leave()
            }
        }

        for _ in 0..<100 {
            group.enter()
            concurrentQueue.async {
                _ = manager.results
                group.leave()
            }
        }
        group.wait()
    }
}
