//
//  CachedBook.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/27/26.
//

struct CachedBook: Codable {
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
      let coverUrl: String?
      let isbn10: String?
      let isbn13: String?
      let provider: String

      enum CodingKeys: String, CodingKey {
          case id, title, authors, publisher, description, categories, provider
          case publishedDate = "published_date"
          case pageCount = "page_count"
          case averageRating = "average_rating"
          case ratingsCount = "ratings_count"
          case coverUrl = "cover_url"
          case isbn10 = "isbn_10"
          case isbn13 = "isbn_13"
      }

      init(from details: BookDetails) {
          self.id = details.id
          self.title = details.title
          self.authors = details.authors
          self.publisher = details.publisher
          self.publishedDate = details.publishedDate
          self.description = details.description
          self.pageCount = details.pageCount
          self.averageRating = details.averageRating
          self.ratingsCount = details.ratingsCount
          self.categories = details.categories
          self.coverUrl = details.imageLinks?.bestAvailable
          self.isbn10 = details.isbn10
          self.isbn13 = details.isbn13
          self.provider = details.provider.rawValue
      }
  }
