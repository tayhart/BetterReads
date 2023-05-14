//
//  SearchResultViewModel.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/18/23.
//

import UIKit

struct Book: Hashable {
    var title: String
    var author: String // TODO: make an array to account for multiple authors
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
            return Book(title: title, author: author, cover: volume.volumeInfo.imageLinks?.thumbnail)
        })
    }

    func requestData(for query: String, completion: @escaping (() -> Void)) {
        dataController.request(query, completion: { [weak self, completion] searchResult in
            self?.data = searchResult
            completion()
        })
    }

    func getVolumeDataForIndex(_ indexPath: IndexPath) -> GoogleBooksResponse.Volume? {
        guard let data = data,
              data.items.indices.contains(indexPath.row)
        else {
            return nil
        }

        return data.items[indexPath.row]
    }
}
