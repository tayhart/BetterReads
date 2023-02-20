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
        static let defaultImageWidth: CGFloat = 128.0
    }

    // MARK: - Variables

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
        return view
    }()

    private lazy var author: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        return label
    }()

    private lazy var title: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    override var intrinsicContentSize: CGSize {
        let height = bookCover.intrinsicContentSize.height + Constants.spacing
        let width = Double.maximum(title.intrinsicContentSize.width, author.intrinsicContentSize.width) + bookCover.intrinsicContentSize.width + (Constants.spacing * 3)
        return CGSize(width: width, height: height)
    }

    // MARK: - Init + View Setup
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }

    private func setupView() {
        addSubview(bookCover)
        addSubview(textStack)

        NSLayoutConstraint.activate([
            bookCover.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.spacing),
            bookCover.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Constants.spacing),
            bookCover.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            textStack.leftAnchor.constraint(equalTo: bookCover.rightAnchor, constant: Constants.spacing),
            textStack.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -Constants.spacing),
            textStack.centerYAnchor.constraint(equalTo: bookCover.centerYAnchor)
        ])
    }

    func setBookCover(cover: UIImage) {
        let group = DispatchGroup()
        group.enter()

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.bookCover.image = cover
            self.bookCover.widthAnchor.constraint(equalToConstant: Double(cover.size.width)).isActive = true
            self.bookCover.heightAnchor.constraint(equalToConstant: Double(cover.size.height)).isActive = true

            group.leave()
        }
        group.notify(queue: .main) { [weak self] in
            self?.layoutIfNeeded()
        }
    }

    func setAuthors(authors: String) {
        author.text = authors
        textStack.addArrangedSubview(author)
        setNeedsLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
