//
//  VolumeDetailsViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit
import Combine

final class VolumeDetailsViewController: UIViewController {
    private struct Constants {
        static let spacing = 14.0
        static let descriptionMargin = 12.0
        static let margins = 10.0
    }

    // MARK: - Design Motifs
    private lazy var horizontalBar: UIView = {
        let designMotif = UIView()
        designMotif.translatesAutoresizingMaskIntoConstraints = false
        designMotif.backgroundColor = .black
        return designMotif
    }()

    // MARK: UI Views
    private var quickLook: QuickLookView = QuickLookView()

    private lazy var descriptionHeader: UILabel = {
        let header = UILabel()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.text = "Description"
        header.apply(type: .headerSmall)
        return header
    }()

    private lazy var detailedDescription: UITextView = {
        let description = UITextView()
        description.translatesAutoresizingMaskIntoConstraints = false
        description.text = viewModel.description
        description.textColor = .black
        description.layer.borderColor = UIColor.black.cgColor
        description.layer.borderWidth = 1.0
        description.layer.cornerRadius = 8.0
        description.contentInset = UIEdgeInsets(
            top: Constants.margins,
            left: Constants.margins,
            bottom: Constants.margins,
            right: Constants.margins)
        description.apply(type: .body)
        description.isEditable = false
        return description
    }()

    // MARK: Variables
    private var coverSink: AnyCancellable?
    private var viewModel: DetailsViewModel

    // MARK: Init + Setup
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setupView()
    }

    private func setupView() {
        view.addSubview(quickLook)
        view.addSubview(descriptionHeader)
        view.addSubview(detailedDescription)

        NSLayoutConstraint.activate([
            quickLook.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLook.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            quickLook.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            quickLook.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),

            descriptionHeader.topAnchor.constraint(equalTo: quickLook.bottomAnchor, constant: Constants.descriptionMargin),
            descriptionHeader.leftAnchor.constraint(equalTo: quickLook.leftAnchor, constant: Constants.descriptionMargin + 5),
            descriptionHeader.rightAnchor.constraint(equalTo: quickLook.rightAnchor),

            detailedDescription.topAnchor.constraint(equalTo: descriptionHeader.bottomAnchor, constant: Constants.margins),
            detailedDescription.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.descriptionMargin),
            detailedDescription.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.descriptionMargin),
            detailedDescription.heightAnchor.constraint(equalToConstant: 150)
        ])
    }

    // MARK: View Controller Lifecycle
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        quickLook.setTitleAndAuthors(title: viewModel.title, authors: viewModel.authors)

        // Subscribe to the cover image being downloaded
        coverSink = viewModel.coverImageSubject.sink { [weak self] in
            guard let cover = $0 else {
                return
            }
            self?.quickLook.setBookCover(cover: cover)
        }
        viewModel.downloadCoverImage()
        view.layoutIfNeeded()
    }

}
