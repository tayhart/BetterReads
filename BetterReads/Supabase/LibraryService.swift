//
//  LibraryService.swift
//  BetterReads
//
//  Service for managing the user's book library.
//

import Foundation
import Supabase

protocol LibraryServiceProtocol {
    func fetchAllBooks() async throws -> [UserBook]
    func fetchBookStatus(bookId: String) async throws -> ReadingStatus?
    func saveBook(_ bookDetails: BookDetails, status: ReadingStatus) async throws
    func updateStatus(bookId: String, status: ReadingStatus) async throws
    func removeBook(bookId: String) async throws
}

@MainActor
final class LibraryService: LibraryServiceProtocol {
    static let shared = LibraryService()

    private let database = SupabaseManager.shared.database
    private let authService = AuthService.shared

    private init() {}

    private var currentUserId: UUID? {
        authService.currentUser?.id
    }

    // MARK: - Fetch Operations

    func fetchAllBooks() async throws -> [UserBook] {
        guard let userId = currentUserId else {
            throw LibraryError.notAuthenticated
        }

        return try await database
            .from("user_books")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("updated_at", ascending: false)
            .execute()
            .value
    }

    func fetchBookStatus(bookId: String) async throws -> ReadingStatus? {
        guard let userId = currentUserId else {
            return nil
        }

        let response: [UserBook] = try await database
            .from("user_books")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("book_id", value: bookId)
            .execute()
            .value

        return response.first?.status
    }

    // MARK: - Write Operations

    func saveBook(_ bookDetails: BookDetails, status: ReadingStatus) async throws {
        guard let userId = currentUserId else {
            throw LibraryError.notAuthenticated
        }

        let book = InsertUserBook(
            userId: userId,
            bookDetails: bookDetails,
            status: status
        )

        try await database
            .from("user_books")
            .upsert(book, onConflict: "user_id,book_id,provider")
            .execute()
    }

    func updateStatus(bookId: String, status: ReadingStatus) async throws {
        guard let userId = currentUserId else {
            throw LibraryError.notAuthenticated
        }

        let update = UpdateUserBookStatus(status: status)

        try await database
            .from("user_books")
            .update(update)
            .eq("user_id", value: userId.uuidString)
            .eq("book_id", value: bookId)
            .execute()
    }

    func removeBook(bookId: String) async throws {
        guard let userId = currentUserId else {
            throw LibraryError.notAuthenticated
        }

        try await database
            .from("user_books")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("book_id", value: bookId)
            .execute()
    }
}

// MARK: - Errors

enum LibraryError: LocalizedError {
    case notAuthenticated
    case bookNotFound

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Please sign in to manage your library."
        case .bookNotFound:
            return "Book not found in your library."
        }
    }
}
