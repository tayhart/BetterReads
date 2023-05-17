//
//  ProfileViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit
import FirebaseAuth

final class ProfileViewController: UIViewController {
    private struct Constants {
        static let bigMargin = 40.0
        static let profPhotoSize = 60.0
        static let smallMargin = 12.0
    }

    // Authentication Handler
    private var authHandler: AuthStateDidChangeListenerHandle?

    // MARK: - Views
    lazy var welcomeHeader: UILabel = {
        let welcome = UILabel()
        welcome.translatesAutoresizingMaskIntoConstraints = false
        welcome.apply(type: .headerBig)
        welcome.textColor = .black
        welcome.numberOfLines = 0
        return welcome
    }()

    lazy var signInButton: UIButton = {
        let authButton = UIButton()
        authButton.translatesAutoresizingMaskIntoConstraints = false
        authButton.setTitle("Sign in or Sign up to see more", for: .normal)
        authButton.addAction(UIAction {_ in
            self.navigationController?.pushViewController(AuthViewController(), animated: true)
        }, for: .touchUpInside)
        authButton.configuration = .filled()
        authButton.tintColor = .ctaColor
        authButton.setTitleColor(.label, for: .normal)

        return authButton
    }()

    lazy var signOutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sign out", for: .normal)
        button.addAction(UIAction {_ in
            self.signOut()
        }, for: .touchUpInside)
        button.configuration = .filled()
        button.tintColor = .ctaColor
        button.setTitleColor(.label, for: .normal)

        return button
    }()

    lazy var profilePhoto: UIView = { // For now just using a placeholder to understand placements
        let view = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: Constants.profPhotoSize,
            height: Constants.profPhotoSize))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .primaryAccentColor
        view.layer.cornerRadius = Constants.profPhotoSize/2
        return view
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        view.addSubview(welcomeHeader)
        view.addSubview(signInButton)
        view.addSubview(signOutButton)
        view.backgroundColor = .primaryBackgroundColor

        NSLayoutConstraint.activate([
            welcomeHeader.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.bigMargin),
            welcomeHeader.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: Constants.bigMargin),
            welcomeHeader.rightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor),


            signInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            signOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            signOutButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }


    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAuthenticationListener()
        if let user = Auth.auth().currentUser {
            updateWelcomeMessage(name: user.displayName)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Auth.auth().removeStateDidChangeListener(authHandler!)
    }

    // MARK: Authentication
    private func setupAuthenticationListener() {
        authHandler = Auth.auth().addStateDidChangeListener { auth, user in
            self.signInButton.isHidden = user != nil
            self.signOutButton.isHidden = user == nil
            self.updateWelcomeMessage(name: user?.displayName)
        }
    }

    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }

    private func updateWelcomeMessage(name: String?) {
        self.welcomeHeader.text = "Welcome, \(name ?? "friend")"
    }
}
