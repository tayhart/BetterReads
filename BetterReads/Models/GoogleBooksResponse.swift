//
//  GoogleBooksResponse.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/3/26.
//


struct GoogleBooksResponse : Codable {
    let kind: String
    let items: [Volume]

    struct Volume : Codable {
        let kind: String
        let id: String
        let etag: String
        let selfLink: String
        let volumeInfo: VolumeInfo
    }

    struct VolumeInfo: Codable {
        let title: String?
        let authors: [String]?
        let publisher: String?
        let publishedDate: String?
        let description: String?
        let industryIdentifiers: [IndustryIdentifiers]?
        let pageCount: Int?
        let dimensions: Dimensions?
        let printType: String?
        let categories: [String]?
        let mainCategory: String?
        let averageRating: Double?
        let ratingsCount: Int?
        let contentVersion: String?
        let imageLinks: ImageLinks?
    }

    struct IndustryIdentifiers: Codable {
        let type: String?
        let identifier: String?
    }

    struct Dimensions: Codable {
        let height: String?
        let width: String?
        let thickness: String?
    }

    struct ImageLinks: Codable {
        let smallThumbnail: String?
        let thumbnail: String?
        let small: String?
        let medium: String?
        let large: String?
        let extraLarge: String?
    }
}
