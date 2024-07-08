//
//  SimplePingPingManagerTests.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 25/04/2024.
//

import XCTest
@testable import SimplePingSwift

final class SimplePingPingManagerTests: XCTestCase {

    let host = "example.com"
    let invalidHost = "xa0com"

    func testPingManagerStartsPingingHost() {
        let expectation = XCTestExpectation(description: "The pingManager starts pinging \(host)")
        var delegate = MockPingManagerDelegate()
        let manager = makeSUT(delegate)
        delegate.didStartPingingExpectation = expectation
        manager.delegate = delegate
        manager.ping(host: Host(name: host))
        wait(for: [expectation], timeout: 5)
    }

    func testPingManagerPingSuccess() {
        let count = 5
        let expectation = XCTestExpectation(description: "The pingManager should send \(count) responses.")
        expectation.expectedFulfillmentCount = count

        var delegate = MockPingManagerDelegate()
        let manager = makeSUT(delegate)
        delegate.didReceiveResponseExpectation = expectation
        manager.delegate = delegate
        manager.ping(host: Host(name: host, config: PingConfiguration(count: count)))

        wait(for: [expectation], timeout: 5)
    }

    func testPingManagerPingFailureForInvalidHost() {
        let expectation = XCTestExpectation(description: "The pingManager should fail.")

        var delegate = MockPingManagerDelegate()
        let manager = makeSUT(delegate)
        delegate.didFailToStartPingingExpectation = expectation
        manager.delegate = delegate
        manager.ping(host: Host(name: invalidHost))

        wait(for: [expectation], timeout: 5)
    }

    func testPingManagerSendsValidResult() {
        let expectation = XCTestExpectation(description: "After a specified number of ping requests, the ping manager should return a valid result.")

        let pingCount = 8
        let config = PingConfiguration(count: pingCount)
        var delegate = MockPingManagerDelegate()
        let manager = makeSUT(delegate)
        delegate.didReceiveResultExpectation = expectation
        delegate.expectedPingCount = pingCount
        manager.delegate = delegate
        manager.ping(host: Host(name: host, config: config))
        wait(for: [expectation], timeout: 5)
    }

    func testPingManagerRequestsTimeoutForUnknowLocalIP() {
        let host = "127.0.0.0"
        let expectation = XCTestExpectation(description: "PingManager requests should time out when pinging unknown local IP.")
        var delegate = MockPingManagerDelegate()
        let manager = makeSUT(delegate)
        delegate.expectingTimeoutResult = true
        delegate.didReceiveTimeoutResultExpectation = expectation
        manager.delegate = delegate
        manager.ping(host: Host(name: host, config: .init(count: 1, timeoutInterval: 2)))
        wait(for: [expectation], timeout: 5)
    }

    func testCanPingMultipleHosts() {
        let expectation = XCTestExpectation(description: "PingManager can ping multiple hosts.")
        let hosts = ["google.com", "facebook.com", "yahoo.co.jp", "node.org", "amazon.in", "x.com"]
        expectation.expectedFulfillmentCount = hosts.count

        var delegate = MockPingManagerDelegate()
        let manager = makeSUT(delegate)
        delegate.didReceiveResultExpectation = expectation

        manager.delegate = delegate
        manager.ping(hosts: Set(hosts.map { Host(name: $0) }))
        wait(for: [expectation], timeout: 5)
    }

    func testMultipleInvalidHosts() {
        let expectation = XCTestExpectation(description: "PingManager fails to ping an invalid host.")
        let hosts = ["g124oogle.com", "faceboo)19k.com", "yah_oo1..co.jp", "ndone12ode.org", "amazon.co.uk.in", "x.com.in.co.jp"]
        expectation.expectedFulfillmentCount = hosts.count

        var delegate = MockPingManagerDelegate()
        let manager = makeSUT(delegate)
        delegate.didFailToStartPingingExpectation = expectation

        manager.delegate = delegate
        manager.ping(hosts: Set(hosts.map { Host(name: $0) }))
        wait(for: [expectation], timeout: 5)
    }

    func testMixHosts() {
        let invalidExpectation = XCTestExpectation(description: "PingManager fails to ping an invalid host.")
        let validExpectation = XCTestExpectation(description: "PingManager pings a valid host.")

        let validHosts = ["google.com", "facebook.com"]
        let invalidHosts = ["yah_oo1..co.jp", "ndone12ode.org", "amazon.co.uk.in", "x.com.in.co.jp"]

        let resultExpectation = XCTestExpectation(description: "PingManager should send a result.")
        resultExpectation.expectedFulfillmentCount = validHosts.count

        validExpectation.expectedFulfillmentCount = validHosts.count
        invalidExpectation.expectedFulfillmentCount = invalidHosts.count

        var delegate = MockPingManagerDelegate()
        let manager = makeSUT(delegate)
        delegate.didStartPingingExpectation = validExpectation
        delegate.didFailToStartPingingExpectation = invalidExpectation
        delegate.didReceiveResultExpectation = resultExpectation
        delegate.expectedPingCount = 5 // Default config


        manager.delegate = delegate
        manager.ping(hosts: Set(validHosts.map { Host(name: $0) } + invalidHosts.map { Host(name: $0) }))
        wait(for: [validExpectation, invalidExpectation, resultExpectation], timeout: 10)
    }

    func testIntenseLoad() {
        let validHosts: Set<String> = ["google.com", "facebook.com", "youtube.com", "amazon.com", "twitter.com", "instagram.com", "linkedin.com", "reddit.com", "wikipedia.org", "netflix.com", "apple.com", "microsoft.com", "ebay.com", "pinterest.com", "wordpress.org", "blogspot.com", "stackoverflow.com", "github.com", "yahoo.com", "bing.com", "tumblr.com", "bbc.co.uk", "cnn.com", "nytimes.com", "whatsapp.com", "espn.com", "quora.com", "imdb.com", "hulu.com", "paypal.com", "spotify.com", "bbc.com", "msn.com", "craigslist.org", "dropbox.com", "etsy.com", "walmart.com", "forbes.com", "theguardian.com", "weather.com", "usatoday.com", "wsj.com", "foxnews.com", "buzzfeed.com", "huffingtonpost.com", "bloomberg.com", "abcnews.go.com", "apnews.com", "cnbc.com", "nationalgeographic.com", "npr.org", "businessinsider.com", "time.com", "theverge.com", "techcrunch.com", "engadget.com", "arstechnica.com", "vice.com", "gizmodo.com", "lifehacker.com", "mashable.com", "thenextweb.com", "venturebeat.com", "wired.com", "slashdot.org", "pcmag.com", "tomsguide.com", "pcworld.com", "digg.com", "digitaltrends.com", "androidcentral.com", "macrumors.com", "cultofmac.com", "androidauthority.com", "androidpolice.com", "9to5mac.com", "theatlantic.com", "newyorker.com", "economist.com", "thetimes.co.uk", "independent.co.uk", "dailymail.co.uk", "express.co.uk", "mirror.co.uk", "thesun.co.uk", "telegraph.co.uk", "metro.co.uk", "standard.co.uk", "guardian.co.uk", "reuters.com", "ft.com", "fortune.com", "newsweek.com", "boston.com", "chicagotribune.com", "latimes.com", "stackoverflow.org", "instagram.org", "twitter.org", "godaddy.com"]

        let pingCount = 2
        let pingInterval = 0.1
        let expectation = XCTestExpectation(description: "PingManager can ping multiple hosts.")
        let expectationCount = (pingCount * validHosts.count) + (validHosts.count * 2) //Why 2? - 1 for each didStart/didFailToStart callback for each one of the validHosts, and 1 for each didFinish.
        expectation.expectedFulfillmentCount = expectationCount

        let delegate = GeneralPingManagerDelegate(expectation: expectation)
        let manager = makeSUT(delegate)
        manager.delegate = delegate

        let validHostsSet = Set(validHosts.map { Host(name: $0, config: .init(count: pingCount, interval: TimeInterval(pingInterval), timeoutInterval: 0.5)) })
        manager.ping(hosts: validHostsSet)
        let timeoutInterval = Double(pingCount * validHosts.count) * Double(pingInterval)
        wait(for: [expectation], timeout: timeoutInterval == 0 ? 1: timeoutInterval)
    }
}

extension SimplePingPingManagerTests {

    private func makeSUT(_ delegate: PingManagerDelegate? = nil) -> SimplePingPingManager {
        let manager = SimplePingPingManager(delegate: delegate)
        trackMemoryLeaks(for: manager)
        return manager
    }
}
