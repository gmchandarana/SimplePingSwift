//
//  Timer+Nullify.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 08/05/2024.
//

import Foundation

extension Optional where Wrapped == Timer {
    /// Invalidates and nullifies the instance
    mutating func nullify() {
        guard let timer = self else { return }
        timer.invalidate()
        self = nil
    }
}
