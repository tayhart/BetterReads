//
//  SearchResultViewCell.swift
//  BetterReads
//
//  Created by Taylor Hartman on 8/29/22.
//

import UIKit

final class SearchResultViewCell: UICollectionViewListCell {
    private struct Constants {
        static let coverWidthMax = 135.0
    }

    private lazy var authorLabel: UILabel = {
        let author = UILabel()
        author.textColor = .black
        author.font = UIFont.preferredFont(forTextStyle: .subheadline)
        author.translatesAutoresizingMaskIntoConstraints = false
        return author
    }()

    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont.preferredFont(forTextStyle: .headline)
        title.textColor = .black
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        return title
    }()

    private lazy var coverImage: UIImageView = {
        let cover = UIImageView(image: UIImage(systemName: "book-icon"))
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.contentMode = .scaleAspectFit
        return cover
    }()

    private var dataTask: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.cornerRadius = 8

        var backgroundConfig = UIBackgroundConfiguration.listPlainCell()
        backgroundConfig.backgroundColor = .ivory
        self.backgroundConfiguration = backgroundConfig
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0

        let disclosureImage = UIImage.chevronRightImage.withRenderingMode(.alwaysTemplate)
        let customAccessory = UICellAccessory.CustomViewConfiguration(
            customView: UIImageView(image: disclosureImage),
            placement: .trailing(displayed: .always))

        self.tintColor = .black
        self.accessories = [.customView(configuration: customAccessory)]
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with book: Book) {
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
            coverImage.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            coverImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            coverImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            coverImage.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.coverWidthMax),

            titleLabel.leftAnchor.constraint(equalTo: coverImage.rightAnchor, constant: 15),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: contentView.rightAnchor, constant: -5),
            titleLabel.bottomAnchor.constraint(equalTo: coverImage.centerYAnchor),

            authorLabel.leftAnchor.constraint(equalTo: titleLabel.leftAnchor),
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10)
        ])
    }
}
