//
//  AuthViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 5/15/23.
//

import UIKit
import SwiftUI

/// UIKit wrapper that hosts the SwiftUI AuthenticationView
/// This allows the SwiftUI view to work within the existing UIKit navigation stack
class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        var authView = AuthenticationView()
        authView.onAuthenticationSuccess = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        let hostingController = UIHostingController(rootView: authView)
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
