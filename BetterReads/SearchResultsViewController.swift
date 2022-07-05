//
//  SearchResultsViewController.swift
//  mibrary
//
//  Created by Taylor Hartman on 3/24/22.
//

import UIKit
//TODO: Implement collection view with a separate data source implementation so it can be switched out
class SearchResultsViewController: UITableViewController {
    var data: GoogleBooksResponse?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = data else { return 0 }
        return data.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = data else { return UITableViewCell() }
        let volume: GoogleBooksResponse.Volume = data.items[indexPath.row]
        let volumeInfo: GoogleBooksResponse.VolumeInfo = volume.volumeInfo

        guard let title = volumeInfo.title,
              let authors = volumeInfo.authors else {
                  return SearchResultTableViewCell(title: "Unknown Title", author: "Unknown Author", imageLink: nil)
              }

        let searchResultCell = SearchResultTableViewCell(title: title,
                                                         author: authors.first,
                                                         imageLink: volumeInfo.imageLinks?.smallThumbnail)

        return searchResultCell
    }

    func populateWithData(responseData: GoogleBooksResponse) {
        data = responseData
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

class SearchResultTableViewCell: UITableViewCell {
    var titleView: UILabel = UILabel()
    var authorView: UILabel = UILabel()
    var coverImage: UIImageView = UIImageView()

    init(title: String, author: String?, imageLink: String?) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "")
        authorView.text = author
        titleView.text = title
        //move all this into lazy initializer
        authorView.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.contentMode = .scaleAspectFit

        if let imageLink = imageLink, let url = URL(string: imageLink)  {
            do {
                //TODO: If the image is above a certain size it needs to be resized
                //add a constant MAX_HEIGHT to this class that determines how large the image should be
                let data = try Data(contentsOf: url)
                let image = UIImage(data: data)
                coverImage.image = image
            } catch {
                // boo
            }
        }

        self.contentView.addSubview(coverImage)
        self.contentView.addSubview(titleView)
        self.contentView.addSubview(authorView)

        NSLayoutConstraint.activate([
            coverImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            coverImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            coverImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            coverImage.widthAnchor.constraint(lessThanOrEqualToConstant: 120),

            titleView.leftAnchor.constraint(greaterThanOrEqualTo: coverImage.rightAnchor),
            titleView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            titleView.bottomAnchor.constraint(equalTo: contentView.centerYAnchor),

            authorView.topAnchor.constraint(equalTo: titleView.bottomAnchor),
            authorView.leftAnchor.constraint(greaterThanOrEqualTo: coverImage.rightAnchor),
            authorView.rightAnchor.constraint(equalTo: titleView.rightAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
