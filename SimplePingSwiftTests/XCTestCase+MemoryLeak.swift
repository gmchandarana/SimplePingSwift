//
//  XCTestCase+MemoryLeak.swift
//  SimplePingSwiftTests
//
//  Created by Gaurav Chandarana on 03/07/2024.
//

import XCTest

extension XCTestCase {

    func trackMemoryLeaks(for object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, "Potential memory leak!", file: file, line: line)
        }
    }
}
