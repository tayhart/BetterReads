//
//  OpenLibraryResponse.swift
//  BetterReads
//
//  Codable model for Open Library API response.
//

import Foundation

/// Response structure from the Open Library search API.
/// API endpoint: https://openlibrary.org/search.json?q={query}
struct OpenLibraryResponse: Codable {
    let numFound: Int
    let start: Int
    let docs: [Doc]

    struct Doc: Codable {
        /// The work key (e.g., "/works/OL45804W")
        let key: String

        /// The book title
        let title: String

        /// Array of author names
        let author_name: [String]?

        /// First publication year
        let first_publish_year: Int?

        /// Median number of pages across editions
        let number_of_pages_median: Int?

        /// Cover ID for constructing cover URLs
        let cover_i: Int?

        /// Array of ISBN identifiers
        let isbn: [String]?

        /// Array of publisher names
        let publisher: [String]?

        /// Array of subject categories
        let subject: [String]?

        /// Average rating (if available)
        let ratings_average: Double?

        /// Number of ratings
        let ratings_count: Int?

        /// Generates a unique ID from the work key
        var workId: String {
            key.replacingOccurrences(of: "/works/", with: "")
        }

        /// Returns the first ISBN-10 (10 characters) if available
        var isbn10: String? {
            isbn?.first { $0.count == 10 }
        }

        /// Returns the first ISBN-13 (13 characters) if available
        var isbn13: String? {
            isbn?.first { $0.count == 13 }
        }
    }
}
