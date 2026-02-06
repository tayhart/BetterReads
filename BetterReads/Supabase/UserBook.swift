//
//  UserBook.swift
//  BetterReads
//
//  Database model for books in a user's reading lists.
//

import Foundation

/// Represents a book in a user's reading list, stored in Supabase
struct UserBook: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let bookId: String  // External ID from Google Books or Open Library
    let status: ReadingStatus
    let title: String
    let authors: [String]?
    let coverUrl: String?
    let pageCount: Int?
    let provider: String  // "googleBooks" or "openLibrary"
    let createdAt: Date
    let updatedAt: Date

    // Optional fields for tracking
    let currentPage: Int?
    let rating: Int?
    let notes: String?
    let startedAt: Date?
    let finishedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case bookId = "book_id"
        case status
        case title
        case authors
        case coverUrl = "cover_url"
        case pageCount = "page_count"
        case provider
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case currentPage = "current_page"
        case rating
        case notes
        case startedAt = "started_at"
        case finishedAt = "finished_at"
    }

    var progressPercentage: Double {
        guard let total = pageCount, total > 0, let current = currentPage else { return 0 }
        return min(Double(current) / Double(total), 1.0)
    }
}

// MARK: - Insert/Update DTOs

/// Data transfer object for inserting a new user book
struct InsertUserBook: Codable {
    let userId: UUID
    let bookId: String
    let status: ReadingStatus
    let title: String
    let authors: [String]?
    let coverUrl: String?
    let pageCount: Int?
    let provider: String

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case bookId = "book_id"
        case status
        case title
        case authors
        case coverUrl = "cover_url"
        case pageCount = "page_count"
        case provider
    }

    /// Create from BookDetails
    init(userId: UUID, bookDetails: BookDetails, status: ReadingStatus) {
        self.userId = userId
        self.bookId = bookDetails.id
        self.status = status
        self.title = bookDetails.title
        self.authors = bookDetails.authors
        self.coverUrl = bookDetails.imageLinks?.bestAvailable
        self.pageCount = bookDetails.pageCount
        self.provider = bookDetails.provider.rawValue
    }
}

/// Data transfer object for updating a user book's status
struct UpdateUserBookStatus: Codable {
    let status: ReadingStatus
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case status
        case updatedAt = "updated_at"
    }

    init(status: ReadingStatus) {
        self.status = status
        self.updatedAt = Date()
    }
}

/// Data transfer object for updating reading progress
struct UpdateUserBookProgress: Codable {
    let currentPage: Int
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case updatedAt = "updated_at"
    }

    init(currentPage: Int) {
        self.currentPage = currentPage
        self.updatedAt = Date()
    }
}
