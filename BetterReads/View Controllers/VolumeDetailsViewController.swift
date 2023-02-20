//
//  VolumeDetailsViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit
import Combine

final class VolumeDetailsViewController: UIViewController {
    /// Quick look container contains the "Quick look" of the book and shows the following:
    /// - Book Cover
    /// - Series + #
    /// - Author
    /// - Length
    var quickLook: QuickLookView = QuickLookView()
    var coverSink: AnyCancellable?

    private var viewModel: DetailsViewModel

    init(viewModel: DetailsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = viewModel.getTitle()
        setupView()
    }

    private func setupView() {
        view.addSubview(quickLook)
        NSLayoutConstraint.activate([
            quickLook.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLook.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            quickLook.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            quickLook.heightAnchor.constraint(equalToConstant: quickLook.intrinsicContentSize.height)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .white
        quickLook.setAuthors(authors: viewModel.getAuthorString())

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
