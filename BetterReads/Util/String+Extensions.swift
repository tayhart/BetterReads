//
//  String+Extensions.swift
//  BetterReads
//

import Foundation

struct DateComponents {
    let year: String
    let month: String
    let day: String

    var yearInt: Int? { Int(year) }
    var monthInt: Int? { Int(month) }
    var dayInt: Int? { Int(day) }
}

enum DateFormat: CaseIterable {
    case yearMonthDay      // YYYY-MM-DD or YYYY/MM/DD
    case monthDayYear      // MM-DD-YYYY or MM/DD/YYYY
    case dayMonthYear      // DD-MM-YYYY or DD/MM/YYYY
    case yearOnly          // YYYY

    var description: String {
        switch self {
        case .yearMonthDay: return "YYYY-MM-DD"
        case .monthDayYear: return "MM-DD-YYYY"
        case .dayMonthYear: return "DD-MM-YYYY"
        case .yearOnly: return "YYYY"
        }
    }
}

extension String {

    /// Parses a date string in the specified format and returns its components.
    /// Supports both `-` and `/` as separators.
    func parseDateComponents(format: DateFormat) -> DateComponents? {
        let separator: Character = self.contains("/") ? "/" : "-"
        let parts = self.split(separator: separator).map(String.init)

        switch format {
        case .yearMonthDay:
            guard parts.count == 3 else { return nil }
            return DateComponents(year: parts[0], month: parts[1], day: parts[2])

        case .monthDayYear:
            guard parts.count == 3 else { return nil }
            return DateComponents(year: parts[2], month: parts[0], day: parts[1])

        case .dayMonthYear:
            guard parts.count == 3 else { return nil }
            return DateComponents(year: parts[2], month: parts[1], day: parts[0])

        case .yearOnly:
            let yearString = parts.count == 1 ? parts[0] : self
            guard yearString.count == 4 else { return nil }
            return DateComponents(year: yearString, month: "01", day: "01")
        }
    }

    /// Attempts to automatically detect the date format and parse components.
    /// Returns nil if the format cannot be determined.
    func parseDateComponentsAutoDetect() -> (components: DateComponents, format: DateFormat)? {
        let separator: Character = self.contains("/") ? "/" : "-"
        let parts = self.split(separator: separator).map(String.init)

        // Year only (e.g., "2024")
        if parts.count == 1 && self.count == 4, Int(self) != nil {
            if let components = parseDateComponents(format: .yearOnly) {
                return (components, .yearOnly)
            }
        }

        guard parts.count == 3 else { return nil }

        // YYYY-MM-DD: First part is 4 digits
        if parts[0].count == 4 {
            if let components = parseDateComponents(format: .yearMonthDay) {
                return (components, .yearMonthDay)
            }
        }

        // MM-DD-YYYY or DD-MM-YYYY: Last part is 4 digits
        if parts[2].count == 4 {
            // Heuristic: if first part > 12, it's likely a day (DD-MM-YYYY)
            if let firstNum = Int(parts[0]), firstNum > 12 {
                if let components = parseDateComponents(format: .dayMonthYear) {
                    return (components, .dayMonthYear)
                }
            }
            // Default to MM-DD-YYYY (US format)
            if let components = parseDateComponents(format: .monthDayYear) {
                return (components, .monthDayYear)
            }
        }

        return nil
    }

    /// Extracts just the year string from a date, auto-detecting format.
    var dateYear: String? {
        parseDateComponentsAutoDetect()?.components.year
    }

    /// Extracts just the month string from a date, auto-detecting format.
    var dateMonth: String? {
        parseDateComponentsAutoDetect()?.components.month
    }

    /// Extracts just the day string from a date, auto-detecting format.
    var dateDay: String? {
        parseDateComponentsAutoDetect()?.components.day
    }
}
