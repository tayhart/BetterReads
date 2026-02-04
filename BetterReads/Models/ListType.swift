//
//  ListType.swift
//  BetterReads
//
//  Reading list categories for organizing books.
//

import Foundation

enum ListType: CaseIterable {
    case toRead, currentlyReading, read, didNotFinish

    var title: String {
        switch self {
        case .toRead:
            return "To read"
        case .currentlyReading:
            return "Currently reading"
        case .read:
            return "Read"
        case .didNotFinish:
            return "Did not finish"
        }
    }
}
