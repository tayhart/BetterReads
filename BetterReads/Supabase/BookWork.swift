//
//  BookWork.swift
//  BetterReads
//

struct BookWork: Codable {
    let workKey: String?
    let title: String
    let authors: [String]?
    let description: String?
    let averageRating: Double?
    let ratingsCount: Int?
    let categories: [String]?
    let coverUrl: String?
    let editions: [BookEdition]

    enum CodingKeys: String, CodingKey {
        case title, authors, description, categories, editions
        case workKey = "work_key"
        case averageRating = "average_rating"
        case ratingsCount = "ratings_count"
        case coverUrl = "cover_url"
    }
}

struct BookEdition: Codable {
    let id: String
    let provider: String
    let isbn10: String?
    let isbn13: String?
    let publisher: String?
    let publishedDate: String?
    let pageCount: Int?
    let coverUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, provider, publisher
        case isbn10 = "isbn_10"
        case isbn13 = "isbn_13"
        case publishedDate = "published_date"
        case pageCount = "page_count"
        case coverUrl = "cover_url"
    }
}
