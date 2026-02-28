//
//  SupabaseSearchProvider.swift
//  BetterReads
//
//  BookSearchProvider implementation using Supabase edge function.
//

import Foundation

/// BookSearchProvider implementation that calls the Supabase `search-books` edge function.
final class SupabaseSearchProvider: BookSearchProvider {

    func search(query: String) async throws -> [BookSearchResult] {
        let response: [CachedBook] = try await SupabaseManager.shared.client.functions
            .invoke(
                "search-books",
                options: .init(query: [URLQueryItem(name: "q", value: query)])
            )

        guard !response.isEmpty else {
            throw BookSearchError.noResults
        }

        return response.compactMap { cached -> BookSearchResult? in
            let provider: BookDetails.BookProvider =
                cached.provider == "Open Library" ? .openLibrary : .googleBooks

            let imageLinks: BookImageLinks? = cached.coverUrl.map {
                BookImageLinks(thumbnail: $0, small: nil, medium: nil, large: nil)
            }

            let details = BookDetails(
                id: cached.id,
                title: cached.title,
                authors: cached.authors,
                publisher: cached.publisher,
                publishedDate: cached.publishedDate,
                description: cached.description,
                pageCount: cached.pageCount,
                averageRating: cached.averageRating,
                ratingsCount: cached.ratingsCount,
                categories: cached.categories,
                imageLinks: imageLinks,
                isbn10: cached.isbn10,
                isbn13: cached.isbn13,
                provider: provider
            )

            let book = Book(
                id: cached.id,
                title: cached.title,
                author: cached.authors?.first ?? "Unknown Author",
                cover: cached.coverUrl
            )

            return BookSearchResult(book: book, details: details)
        }
    }
}
