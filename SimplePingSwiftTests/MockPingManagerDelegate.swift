//
//  MockPingManagerDelegate.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 02/06/2024.
//

import XCTest
@testable import SimplePingSwift

struct MockPingManagerDelegate: PingManagerDelegate {

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

struct GeneralPingManagerDelegate: PingManagerDelegate {

    let expectation: XCTestExpectation

    func didStartPinging(host: String) {
        expectation.fulfill()
    }

    func didFailToStartPinging(host: String, error: any Error) {
        expectation.fulfill()
    }

    func didReceiveResponseFrom(host: String, response: Result<TimeInterval, any Error>) {
        expectation.fulfill()
    }

    func didFinishPinging(host: String, result: SimplePingSwift.PingResult) {
        expectation.fulfill()
    }
}
