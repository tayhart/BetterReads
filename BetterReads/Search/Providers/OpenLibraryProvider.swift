//
//  OpenLibraryProvider.swift
//  BetterReads
//
//  BookSearchProvider implementation for Open Library API.
//

import Foundation

/// BookSearchProvider implementation that fetches data from Open Library API.
final class OpenLibraryProvider: BookSearchProvider {

    private struct Constants {
        static let searchBaseURL = "https://openlibrary.org/search.json"
        static let coverBaseURL = "https://covers.openlibrary.org/b/id"
    }

    func search(query: String) async throws -> [BookSearchResult] {
        guard var components = URLComponents(string: Constants.searchBaseURL) else {
            throw BookSearchError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "20")
        ]

        guard let url = components.url else {
            throw BookSearchError.invalidURL
        }

        let data: Data
        do {
            let (responseData, _) = try await URLSession.shared.data(from: url)
            data = responseData
        } catch {
            throw BookSearchError.networkError(error)
        }

        let response: OpenLibraryResponse
        do {
            response = try JSONDecoder().decode(OpenLibraryResponse.self, from: data)
        } catch {
            throw BookSearchError.decodingError(error)
        }

        if response.docs.isEmpty {
            throw BookSearchError.noResults
        }

        return response.docs.compactMap { doc -> BookSearchResult? in
            let coverURL = doc.cover_i.map { coverId in
                "\(Constants.coverBaseURL)/\(coverId)-M.jpg"
            }

            let book = Book(
                id: doc.workId,
                title: doc.title,
                author: doc.author_name?.first ?? "Unknown Author",
                cover: coverURL
            )

            let details = mapDocToBookDetails(doc)

            return BookSearchResult(book: book, details: details)
        }
    }

    /// Maps an OpenLibraryResponse.Doc to a provider-agnostic BookDetails model.
    private func mapDocToBookDetails(_ doc: OpenLibraryResponse.Doc) -> BookDetails {
        // Build image links from cover ID
        var imageLinks: BookImageLinks?
        if let coverId = doc.cover_i {
            imageLinks = BookImageLinks(
                thumbnail: "\(Constants.coverBaseURL)/\(coverId)-S.jpg",
                small: "\(Constants.coverBaseURL)/\(coverId)-S.jpg",
                medium: "\(Constants.coverBaseURL)/\(coverId)-M.jpg",
                large: "\(Constants.coverBaseURL)/\(coverId)-L.jpg"
            )
        }

        // Format published date from year
        let publishedDate = doc.first_publish_year.map { String($0) }

        return BookDetails(
            id: doc.workId,
            title: doc.title,
            authors: doc.author_name,
            publisher: doc.publisher?.first,
            publishedDate: publishedDate,
            description: nil, // Open Library search doesn't include descriptions
            pageCount: doc.number_of_pages_median,
            averageRating: doc.ratings_average,
            ratingsCount: doc.ratings_count,
            categories: doc.subject?.prefix(5).map { String($0) }, // Limit categories
            imageLinks: imageLinks,
            isbn10: doc.isbn10,
            isbn13: doc.isbn13,
            provider: .openLibrary
        )
    }
}
