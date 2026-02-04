//
//  BookSearchProvider.swift
//  BetterReads
//
//  Protocol definition for book search providers.
//

import Foundation

/// Protocol that defines the interface for book search providers.
/// Implementations can fetch book data from different APIs (Google Books, Open Library, etc.)
protocol BookSearchProvider {
    /// Searches for books matching the given query.
    /// - Parameter query: The search query string
    /// - Returns: An array of BookSearchResult containing book and detail information
    /// - Throws: BookSearchError if the search fails
    func search(query: String) async throws -> [BookSearchResult]
}

/// A search result containing both the simplified Book model and full BookDetails.
struct BookSearchResult: Identifiable {
    let book: Book
    let details: BookDetails

    var id: String { book.id }
}

/// Errors that can occur during book search operations.
enum BookSearchError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case noResults
    case apiKeyMissing

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .noResults:
            return "No results found"
        case .apiKeyMissing:
            return "API key is missing"
        }
    }
}
