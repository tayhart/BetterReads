//
//  BookDetails.swift
//  BetterReads
//
//  Provider-agnostic detail model for book information.
//

import Foundation

/// Provider-agnostic model containing detailed book information.
/// This replaces direct use of GoogleBooksResponse.Volume throughout the app.
struct BookDetails {
    let id: String
    let title: String
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let pageCount: Int?
    let averageRating: Double?
    let ratingsCount: Int?
    let categories: [String]?
    let imageLinks: BookImageLinks?
    let isbn10: String?
    let isbn13: String?
    let provider: BookProvider

    /// The data provider source for this book
    enum BookProvider: String {
        case googleBooks = "Google Books"
        case openLibrary = "Open Library"
    }
}

/// Provider-agnostic image links for book covers.
struct BookImageLinks {
    let thumbnail: String?
    let small: String?
    let medium: String?
    let large: String?

    /// Returns the best available image URL, preferring larger sizes.
    var bestAvailable: String? {
        large ?? medium ?? small ?? thumbnail
    }
}
