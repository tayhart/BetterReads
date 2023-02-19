//
//  QuickLookView.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/18/23.
//

import Foundation
import UIKit

final class QuickLookView: UIView {
    private struct Constants {
        static let spacing = 10.0
        static let bookInformationSpacing = 8.0
        static let defaultImageWidth: CGFloat = 65.0
    }

    // MARK: - Variables
    let book: Book //will be a different thing - will be a vm

    // MARK: - Views
    private lazy var bookCover: UIImageView = {
        let cover = UIImageView(image: UIImage(systemName: "book-icon"))
        cover.translatesAutoresizingMaskIntoConstraints = false
        return cover
    }()

    private lazy var textStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.bookInformationSpacing

        view.addArrangedSubview(title)
        view.addArrangedSubview(author)
        return view
    }()

    private lazy var author: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = book.author
        return label
    }()

    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = book.title
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    override var intrinsicContentSize: CGSize {
        let height = bookCover.intrinsicContentSize.height + Constants.spacing
        let width = Double.maximum(title.intrinsicContentSize.width, author.intrinsicContentSize.width) + bookCover.intrinsicContentSize.width + (Constants.spacing * 3)
        return CGSize(width: width, height: height)
    }

    // MARK: - Init + View Setup
    init(_ book: Book) {
        self.book = book
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false

        addSubview(bookCover)
        addSubview(textStack)

        NSLayoutConstraint.activate([
            bookCover.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.spacing),
            bookCover.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Constants.spacing),
            bookCover.widthAnchor.constraint(equalToConstant: Double(bookCover.image?.size.width ?? Constants.defaultImageWidth)),
            bookCover.heightAnchor.constraint(equalToConstant: Double(bookCover.image?.size.height ?? Constants.defaultImageWidth)),
            bookCover.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            textStack.leftAnchor.constraint(equalTo: bookCover.rightAnchor, constant: Constants.spacing),
            textStack.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -Constants.spacing),
            textStack.centerYAnchor.constraint(equalTo: bookCover.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
