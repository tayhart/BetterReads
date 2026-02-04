//
//  BookDetailsViewController.swift
//  BetterReads
//
//  UIKit wrapper that hosts the SwiftUI BookDetailsView.
//

import UIKit
import SwiftUI

/// UIKit wrapper that hosts the SwiftUI BookDetailsView
final class BookDetailsViewController: UIViewController {

    private let bookDetails: BookDetails

    init(bookDetails: BookDetails) {
        self.bookDetails = bookDetails
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let detailsView = BookDetailsView(bookDetails: bookDetails)
        let hostingController = UIHostingController(rootView: detailsView)

        addChild(hostingController)
        view.addSubview(hostingController.view)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }
}
