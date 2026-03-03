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
        let response: [BookWork] = try await SupabaseManager.shared.client.functions
            .invoke(
                "search-books",
                options: .init(query: [URLQueryItem(name: "q", value: query)])
            )

        guard !response.isEmpty else {
            throw BookSearchError.noResults
        }

        return response.compactMap { work -> BookSearchResult? in
            let primaryEdition = work.editions.first
            let workId = work.workKey ?? primaryEdition?.id ?? UUID().uuidString

            let provider: BookDetails.BookProvider =
                primaryEdition?.provider == "openLibrary" ? .openLibrary : .googleBooks

            let coverUrl = work.coverUrl ?? primaryEdition?.coverUrl
            let imageLinks: BookImageLinks? = coverUrl.map {
                BookImageLinks(thumbnail: $0, small: nil, medium: nil, large: nil)
            }

            let details = BookDetails(
                id: workId,
                title: work.title,
                authors: work.authors,
                publisher: primaryEdition?.publisher,
                publishedDate: primaryEdition?.publishedDate,
                description: work.description,
                pageCount: primaryEdition?.pageCount,
                averageRating: work.averageRating,
                ratingsCount: work.ratingsCount,
                categories: work.categories,
                imageLinks: imageLinks,
                isbn10: primaryEdition?.isbn10,
                isbn13: primaryEdition?.isbn13,
                provider: provider
            )

            let book = Book(
                id: workId,
                title: work.title,
                author: work.authors?.first ?? "Unknown Author",
                cover: coverUrl
            )

            return BookSearchResult(book: book, details: details)
        }
    }
}
