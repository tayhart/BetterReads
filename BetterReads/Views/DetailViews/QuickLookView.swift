//
//  QuickLookView.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/18/23.
//

import UIKit

/// Quick look container contains the "Quick look" of the book and shows the following:
/// - Book Cover
/// - Book Title
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

    /// The container holds the book cover
    private lazy var bookCoverContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(bookCover)

        NSLayoutConstraint.activate([
            container.leftAnchor.constraint(equalTo: bookCover.leftAnchor, constant: -Constants.bookInformationSpacing),
            container.topAnchor.constraint(equalTo: bookCover.topAnchor, constant: -Constants.bookInformationSpacing),
            container.rightAnchor.constraint(equalTo: bookCover.rightAnchor, constant: Constants.bookInformationSpacing),
            container.bottomAnchor.constraint(equalTo: bookCover.bottomAnchor, constant: Constants.bookInformationSpacing)
        ])
        return container
    }()

    private lazy var bookCover: UIImageView = {
        let cover = UIImageView(image: UIImage(systemName: "book-icon"))
        cover.translatesAutoresizingMaskIntoConstraints = false
        return cover
    }()

    private lazy var basicInfoStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .leading
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = Constants.bookInformationSpacing
        return view
    }()

    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        label.apply(type: .subHeader)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading..."
        label.apply(type: .headerBig)
        label.textColor = .black
        label.numberOfLines = 0
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
        addSubview(basicInfoStack)
        basicInfoStack.addArrangedSubview(titleLabel)
        basicInfoStack.addArrangedSubview(authorLabel)

        NSLayoutConstraint.activate([
            bookCoverContainer.leftAnchor.constraint(equalTo: self.leftAnchor, constant: Constants.spacing),
            bookCoverContainer.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.spacing),
            bookCoverContainer.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            basicInfoStack.centerYAnchor.constraint(equalTo: bookCover.centerYAnchor),
            basicInfoStack.leftAnchor.constraint(equalTo: bookCoverContainer.rightAnchor, constant: Constants.spacing),
            basicInfoStack.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor, constant: -Constants.spacing),
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
