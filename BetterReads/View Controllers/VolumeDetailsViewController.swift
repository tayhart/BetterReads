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
        static let descriptionMargin = 25.0
    }

    // MARK: - Design Motifs
    private lazy var primaryAccentBackgroundDesignElement: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMinXMinYCorner]
        view.backgroundColor = .primaryAccentColor
        return view
    }()

    private lazy var secondaryAccentBackgroundDesignElement: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12
        view.layer.maskedCorners = [.layerMaxXMinYCorner]
        view.backgroundColor = .secondaryAccentColor
        return view
    }()

    private lazy var horizontalBar: UIView = {
        let designMotif = UIView()
        designMotif.translatesAutoresizingMaskIntoConstraints = false
        designMotif.backgroundColor = .black
        return designMotif
    }()

    // MARK: UI Views
    private var quickLook: QuickLookView = QuickLookView()

    private lazy var descriptionContainer: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(detailedDescription)
        container.backgroundColor = .ivory
        container.layer.borderColor = UIColor.black.cgColor
        container.layer.borderWidth = 2.0

        NSLayoutConstraint.activate([
            detailedDescription.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 10),
            detailedDescription.rightAnchor.constraint(equalTo: container.rightAnchor, constant: -10),
            detailedDescription.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            detailedDescription.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10)
        ])
        return container
    }()

    private lazy var detailedDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.text = viewModel.description
        label.textColor = .black
        label.apply(type: .body)
        label.backgroundColor = .clear
        return label
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
        view.backgroundColor = .primaryBackgroundColor
        setupView()
    }

    private func setupView() {
        view.addSubview(quickLook)
        view.addSubview(descriptionContainer)
        setupBackgroundDesign() // setup design motifs

        NSLayoutConstraint.activate([
            quickLook.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLook.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            quickLook.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            quickLook.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),

            descriptionContainer.topAnchor.constraint(equalTo: quickLook.bottomAnchor, constant: Constants.descriptionMargin),
            descriptionContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: Constants.descriptionMargin),
            descriptionContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -Constants.descriptionMargin),
            descriptionContainer.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    private func setupBackgroundDesign() {
        view.insertSubview(primaryAccentBackgroundDesignElement, belowSubview: quickLook)
        view.insertSubview(secondaryAccentBackgroundDesignElement, belowSubview: descriptionContainer)
        view.insertSubview(horizontalBar, belowSubview: quickLook)

        NSLayoutConstraint.activate([
            primaryAccentBackgroundDesignElement.topAnchor.constraint(equalTo: quickLook.bookCenterYAnchor, constant: 40),
            primaryAccentBackgroundDesignElement.rightAnchor.constraint(equalTo: view.rightAnchor),
            primaryAccentBackgroundDesignElement.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            primaryAccentBackgroundDesignElement.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            secondaryAccentBackgroundDesignElement.topAnchor.constraint(equalTo: descriptionContainer.topAnchor, constant: -20),
            secondaryAccentBackgroundDesignElement.leftAnchor.constraint(equalTo: view.leftAnchor),
            secondaryAccentBackgroundDesignElement.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            secondaryAccentBackgroundDesignElement.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),

            horizontalBar.heightAnchor.constraint(equalToConstant: 2),
            horizontalBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            horizontalBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            horizontalBar.centerYAnchor.constraint(equalTo: quickLook.bookCenterYAnchor),
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
