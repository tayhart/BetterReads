//
//  SearchResultViewModel.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/18/23.
//

import UIKit

struct Book: Hashable {
    var title: String
    var author: String //make an array to account for multiple authors
    var cover: String?
}

final class SearchResultViewModel {
    private let dataController = BooksDataController()
    private var data: GoogleBooksResponse?

    var quickLookData: [Book] {
        guard let data = data else { return [] }

        return data.items.compactMap({ volume in
            guard let title = volume.volumeInfo.title,
                  let author = volume.volumeInfo.authors?[0] else {
                return nil
            }

            guard let coverURL =  volume.volumeInfo.imageLinks?.thumbnail else {
                return Book(title: title, author: author, cover: nil)
            }

            return Book(title: title, author: author, cover: coverURL)
        })
    }
    

    func requestData(for query: String, completion: @escaping (() -> Void)) {
        dataController.request(query, completion: { [weak self, completion] searchResult in
            self?.data = searchResult
            completion()
        })
    }
}
