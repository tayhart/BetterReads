//
//  ProfileViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit

final class ProfileViewController: UIViewController {
    private struct Constants {
        static let bigMargin = 65.0
        static let profPhotoSize = 120.0
    }
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
        view.addSubview(profilePhoto)
        view.backgroundColor = .primaryBackgroundColor

        NSLayoutConstraint.activate([
            profilePhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.bigMargin),
            profilePhoto.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor),
            profilePhoto.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profilePhoto.widthAnchor.constraint(equalToConstant: Constants.profPhotoSize),
            profilePhoto.heightAnchor.constraint(equalToConstant: Constants.profPhotoSize)
        ])
    }
}
