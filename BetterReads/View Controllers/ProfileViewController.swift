//
//  ProfileViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit
import SwiftUI

/// UIKit wrapper that hosts the SwiftUI ProfileView
final class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var profileView = ProfileView()
        profileView.onSignInTapped = { [weak self] in
            self?.navigationController?.pushViewController(AuthViewController(), animated: true)
        }

        let hostingController = UIHostingController(rootView: profileView)
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
