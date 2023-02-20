//
//  QuickLookView.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/18/23.
//

import Foundation
import UIKit

/// Quick look container contains the "Quick look" of the book and shows the following:
/// - Book Cover
/// - Author
final class QuickLookView: UIView {
    private struct Constants {
        static let spacing = 12.0
        static let bookInformationSpacing = 10.0
        static let defaultImageWidth: CGFloat = 128.0
    }

    // MARK: - Variables
    var bookCenterYAnchor: NSLayoutYAxisAnchor {
        return bookCover.centerYAnchor
    }
    // MARK: - Views

    /// The container holds the book cover and also adds some basic design elements like a border
    private lazy var bookCoverContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bookCover)
        container.backgroundColor = .cream
        container.layer.borderColor = UIColor.black.cgColor
        container.layer.borderWidth = 2.0

        NSLayoutConstraint.activate([
            container.leftAnchor.constraint(equalTo: bookCover.leftAnchor, constant: -10),
            container.topAnchor.constraint(equalTo: bookCover.topAnchor, constant: -10),
            container.rightAnchor.constraint(equalTo: bookCover.rightAnchor, constant: 10),
            container.bottomAnchor.constraint(equalTo: bookCover.bottomAnchor, constant: 10)
        ])
        return container
    }()

    private lazy var bookCover: UIImageView = {
        let cover = UIImageView(image: UIImage(systemName: "book-icon"))
        cover.translatesAutoresizingMaskIntoConstraints = false
        return cover
    }()

    private lazy var textStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.bookInformationSpacing
        return view
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        label.apply(type: .subHeader)
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        label.apply(type: .headerBig)
        return label
    }()

    // MARK: - Init + View Setup
    init() {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }

    private func setupView() {
        addSubview(bookCoverContainer)
        addSubview(textStack)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(authorLabel)

        NSLayoutConstraint.activate([
            bookCoverContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: Constants.spacing),
            bookCoverContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.spacing),

            textStack.centerXAnchor.constraint(equalTo: bookCover.centerXAnchor),
            textStack.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor, constant: Constants.spacing),
            textStack.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor, constant: -Constants.spacing),
            textStack.topAnchor.constraint(equalTo: bookCover.bottomAnchor, constant: 16),
            textStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Constants.spacing)
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

    func setTitleAndAuthors(title: String, authors: String) {
        titleLabel.text = title
        authorLabel.text = authors
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
