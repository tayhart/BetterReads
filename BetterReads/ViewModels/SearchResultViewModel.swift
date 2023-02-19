//
//  SearchResultViewModel.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/18/23.
//

import UIKit

struct Book: Hashable {
    var title: String
    var author: String
    var cover: UIImage //change to String or to URL instead of the image
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


            if let coverURL =  volume.volumeInfo.imageLinks?.thumbnail,
               let url = URL(string: coverURL) {
                do {
                    //TODO: If the image is above a certain size it needs to be resized
                    //add a constant MAX_HEIGHT to this class that determines how large the image should be
                    let data = try Data(contentsOf: url)
                    let cover = UIImage(data: data)
                    return Book(title: title, author: author, cover: cover ?? UIImage(systemName: "book-icon")!)
                } catch {
                    // bummer
                    return nil
                }
            } else {
                let cover = UIImage(systemName: "book")!
                return Book(title: title, author: author, cover: cover)
            }
        })
    }
    

    func requestData(for query: String, completion: @escaping (() -> Void)) {
        dataController.request(query, completion: { [weak self, completion] searchResult in
            self?.data = searchResult
            completion()
        })
    }
}
