//
//  SearchViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 3/18/22.
//

import UIKit
import SwiftUI

/// UIKit wrapper that hosts the SwiftUI SearchView
class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var searchView = SearchView()
        searchView.onProfileTapped = { [weak self] in
            self?.navigationController?.pushViewController(ProfileViewController(), animated: true)
        }
        searchView.onVolumeTapped = { [weak self] volume in
            let detailsVC = VolumeDetailsViewController(volume: volume)
            self?.navigationController?.pushViewController(detailsVC, animated: true)
        }

        let hostingController = UIHostingController(rootView: searchView)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        navigationController?.setToolbarHidden(false, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}
