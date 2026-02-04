//
//  GoogleBooksProvider.swift
//  BetterReads
//
//  BookSearchProvider implementation for Google Books API.
//

import Foundation

/// BookSearchProvider implementation that fetches data from Google Books API.
final class GoogleBooksProvider: BookSearchProvider {

    private struct Constants {
        static let apiKey = Bundle.main.object(forInfoDictionaryKey: "books_API") as? String
        static let scheme = "https"
        static let host = "www.googleapis.com"
        static let path = "/books/v1/volumes"
    }

    func search(query: String) async throws -> [BookSearchResult] {
        guard let apiKey = Constants.apiKey, !apiKey.isEmpty else {
            throw BookSearchError.apiKeyMissing
        }

        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.path = Constants.path
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "key", value: apiKey)
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

        let response: GoogleBooksResponse
        do {
            response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
        } catch {
            throw BookSearchError.decodingError(error)
        }

        return response.items.compactMap { volume -> BookSearchResult? in
            guard let title = volume.volumeInfo.title else {
                return nil
            }

            let coverLink = volume.volumeInfo.imageLinks?.thumbnail?
                .replacingOccurrences(of: "&edge=curl", with: "")

            let book = Book(
                id: volume.id,
                title: title,
                author: volume.volumeInfo.authors?.first ?? "Unknown Author",
                cover: coverLink
            )

            let details = mapVolumeToBookDetails(volume)

            return BookSearchResult(book: book, details: details)
        }
    }

    /// Maps a GoogleBooksResponse.Volume to a provider-agnostic BookDetails model.
    private func mapVolumeToBookDetails(_ volume: GoogleBooksResponse.Volume) -> BookDetails {
        let volumeInfo = volume.volumeInfo

        // Extract ISBN identifiers
        var isbn10: String?
        var isbn13: String?
        if let identifiers = volumeInfo.industryIdentifiers {
            for identifier in identifiers {
                if identifier.type == "ISBN_10" {
                    isbn10 = identifier.identifier
                } else if identifier.type == "ISBN_13" {
                    isbn13 = identifier.identifier
                }
            }
        }

        // Map image links
        var imageLinks: BookImageLinks?
        if let links = volumeInfo.imageLinks {
            // Remove edge curl parameter from URLs
            let cleanURL: (String?) -> String? = { url in
                url?.replacingOccurrences(of: "&edge=curl", with: "")
            }

            imageLinks = BookImageLinks(
                thumbnail: cleanURL(links.thumbnail ?? links.smallThumbnail),
                small: cleanURL(links.small),
                medium: cleanURL(links.medium),
                large: cleanURL(links.large ?? links.extraLarge)
            )
        }

        return BookDetails(
            id: volume.id,
            title: volumeInfo.title ?? "Unknown",
            authors: volumeInfo.authors,
            publisher: volumeInfo.publisher,
            publishedDate: volumeInfo.publishedDate,
            description: volumeInfo.description,
            pageCount: volumeInfo.pageCount,
            averageRating: volumeInfo.averageRating,
            ratingsCount: volumeInfo.ratingsCount,
            categories: volumeInfo.categories,
            imageLinks: imageLinks,
            isbn10: isbn10,
            isbn13: isbn13,
            provider: .googleBooks
        )
    }
}
