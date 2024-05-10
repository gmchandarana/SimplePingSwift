//
//  PingRequestStatus.swift
//  SimplePingSwift
//
//  Created by Gaurav Chandarana on 09/05/2024.
//

import Foundation

enum PingRequestStatus {

    case sent(Date)
    case received(TimeInterval)
    case failed(Error)

    init(request: Result<Date, Error>) {
        switch request {
        case .success(let date): self = .sent(date)
        case .failure(let error): self = .failed(error)
        }
    }

    func response() -> Result<TimeInterval, Error>? {
        switch self {
        case .sent: nil
        case .received(let timeInterval): .success(timeInterval)
        case .failed(let error): .failure(error)
        }
    }
}

extension PingRequestStatus: Equatable {

    static func == (lhs: PingRequestStatus, rhs: PingRequestStatus) -> Bool {
        switch (lhs, rhs) {
        case let (.sent(lhsDate), .sent(rhsDate)): lhsDate == rhsDate
        case let (.received(lhsLatency), .received(rhsLatency)): lhsLatency == rhsLatency
        case let (.failed(lhsError), .failed(rhsError)): lhsError.localizedDescription == rhsError.localizedDescription
        default: false
        }
    }
}
