//
//  SearchResultViewCell.swift
//  BetterReads
//
//  Created by Taylor Hartman on 8/29/22.
//

import UIKit

final class SearchResultViewCell: UICollectionViewListCell {

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
        return title
    }()

    private var coverImage: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.layer.cornerRadius = 8
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(cover: UIImage, author: String, title: String) {
        accessories = [.disclosureIndicator()]
        authorLabel.text = author
        titleLabel.text = title
        coverImage = UIImageView(image: cover)

        guard let coverImage = coverImage else {
            return
        }

        contentView.addSubview(coverImage)
        contentView.addSubview(authorLabel)
        contentView.addSubview(titleLabel)
        contentView.layoutMargins = UIEdgeInsets(
            top: 10,
            left: 10,
            bottom: 10,
            right: 10)

        NSLayoutConstraint.activate([
            coverImage.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            coverImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            titleLabel.leftAnchor.constraint(equalTo: coverImage.rightAnchor, constant: 10),
            titleLabel.bottomAnchor.constraint(equalTo: coverImage.centerYAnchor),

            authorLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        ])

    }

}
