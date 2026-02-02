//
//  VolumeDetailsViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit
import SwiftUI

/// UIKit wrapper that hosts the SwiftUI VolumeDetailsView
final class VolumeDetailsViewController: UIViewController {

    private let volume: GoogleBooksResponse.Volume

    init(volume: GoogleBooksResponse.Volume) {
        self.volume = volume
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let detailsView = VolumeDetailsView(volume: volume)
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
