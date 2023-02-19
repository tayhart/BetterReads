//
//  VolumeDetailsViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit

final class VolumeDetailsViewController: UIViewController {
    var volume: Book

    /// Quick look container contains the "Quick look" of the book and shows the following:
    /// - Book Cover
    /// - Series + #
    /// - Author
    /// - Length
    let quickLook: QuickLookView

    init(with volume: Book) { //TODO: convert to vm
        self.volume = volume
        quickLook = QuickLookView(volume)
        super.init(nibName: nil, bundle: nil)
        title = volume.title
        setupView()
    }

    private func setupView() {
        view.addSubview(quickLook)
        NSLayoutConstraint.activate([
            quickLook.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            quickLook.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            quickLook.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            quickLook.heightAnchor.constraint(equalToConstant: quickLook.book.cover.size.height)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .white
    }

}
