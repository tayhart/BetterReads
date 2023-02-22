//
//  DetailsViewModel.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/19/23.
//

import UIKit
import Combine

final class DetailsViewModel {

    private var volume: GoogleBooksResponse.Volume
    let coverImageSubject = PassthroughSubject<UIImage?, Never>()

    var description: String {
        return volume.volumeInfo.description ?? "No description available"
    }

    var numberOfPages: Int? {
        return volume.volumeInfo.pageCount
    }

    var title: String {
        return volume.volumeInfo.title ?? "Unknown"
    }

    var authors: String {
        guard let authors = volume.volumeInfo.authors else {
            return "No author found"
        }
        return authors.map {
            guard $0 != authors.last else {
                return $0
            }
            return $0 + " ,"
        }.joined()
    }

    init(_ volume: GoogleBooksResponse.Volume) {
        self.volume = volume
    }

    func downloadCoverImage() {
        guard let urlString = volume.volumeInfo.imageLinks?.large ??
                volume.volumeInfo.imageLinks?.medium ??
                volume.volumeInfo.imageLinks?.small ??
                volume.volumeInfo.imageLinks?.thumbnail,
              let url = URL(string: urlString) else {
            return
        }

        URLSession.shared.downloadTask(with: url) { [weak self] url, response, error in
            guard let cache = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first,
                let location = url else {
                // download error
                return
            }

            do {
                let file = cache.appendingPathComponent("\(UUID().uuidString).jpg")

                try FileManager.default.moveItem(atPath: location.path, toPath: file.path)
                let cover = UIImage(contentsOfFile: file.path)
                self?.coverImageSubject.send(cover)
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
