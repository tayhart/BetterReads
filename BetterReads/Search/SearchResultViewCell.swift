//
//  SearchResultViewCell.swift
//  BetterReads
//
//  Created by Taylor Hartman on 8/29/22.
//

import UIKit

final class SearchResultViewCell: UICollectionViewListCell {
    private struct Constants {
        static let coverWidth = 128.0
    }

    private lazy var authorLabel: UILabel = {
        let author = UILabel()
        author.textColor = .secondaryLabel
        author.font = UIFont.preferredFont(forTextStyle: .subheadline)
        author.translatesAutoresizingMaskIntoConstraints = false
        return author
    }()

    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont.preferredFont(forTextStyle: .headline)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        return title
    }()

    private lazy var coverImage: UIImageView = {
        let cover = UIImageView(image: UIImage(systemName: "book-icon"))
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.contentMode = .scaleAspectFill
        return cover
    }()

    private var dataTask: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 8
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with book: Book) {
        accessories = [.disclosureIndicator()]
        authorLabel.text = book.author
        titleLabel.text = book.title

        if let url = URL(string: book.cover ?? "") {
            dataTask = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        self?.coverImage.image = UIImage(data: data)
                    }
                }
            }
            self.dataTask?.resume()
        }

        contentView.addSubview(coverImage)
        contentView.addSubview(authorLabel)
        contentView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            coverImage.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            coverImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            coverImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            coverImage.widthAnchor.constraint(equalToConstant: Constants.coverWidth),

            titleLabel.leftAnchor.constraint(equalTo: coverImage.rightAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5),
            titleLabel.bottomAnchor.constraint(equalTo: coverImage.centerYAnchor),

            authorLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        ])
    }
}
