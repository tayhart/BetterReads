//
//  DataController.swift
//  mibrary
//
//  Created by Taylor Hartman on 3/18/22.
//

import Foundation

class DataController {

    private struct Constants {
        static let APIKey =  Bundle.main.object(forInfoDictionaryKey: "books_API") as? String
        static let scheme: String = "https"
        static let host: String = "www.googleapis.com"
        static let path: String = "/books/v1/volumes"
    }

    func request(_ query: String, completion: @escaping (GoogleBooksResponse) -> Void) {
        var requestComponents = URLComponents()
        requestComponents.scheme = Constants.scheme
        requestComponents.host = Constants.host
        requestComponents.path = Constants.path
        requestComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "key", value: Constants.APIKey)
        ]
        
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        let urlRequest = URLRequest(url: requestComponents.url!)
        let task = urlSession.dataTask(with: urlRequest) {
            data, response, error in

            if error != nil {
                print(error.debugDescription)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let results = try decoder.decode(GoogleBooksResponse.self, from: data!)
                completion(results)
            } catch DecodingError.dataCorrupted(let context) {
                print(context.debugDescription)
            } catch DecodingError.keyNotFound(let key, let context) {
                print("\(key.stringValue) was not found, \(context.debugDescription)")
            } catch DecodingError.typeMismatch(let type, let context) {
                print("\(type) was expected, \(context.debugDescription)")
            } catch DecodingError.valueNotFound(let type, let context) {
                print("no value was found for \(type), \(context.debugDescription)")
            } catch {
                print("Unknown error experienced")
            }
        }
        task.resume()
    }
}

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
