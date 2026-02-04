//
//  ReadingStatus.swift
//  BetterReads
//
//  Reading status categories
//

import Foundation

enum ReadingStatus: String, Codable, CaseIterable {
    case toRead = "to_read"
    case currentlyReading = "currently_reading"
    case read = "read"
    case didNotFinish = "did_not_finish"

    var displayTitle: String {
        switch self {
        case .toRead: return "To Read"
        case .currentlyReading: return "Currently Reading"
        case .read: return "Read"
        case .didNotFinish: return "Did Not Finish"
        }
    }
}
