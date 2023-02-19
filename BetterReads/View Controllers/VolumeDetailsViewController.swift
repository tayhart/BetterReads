//
//  VolumeDetailsViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit

final class VolumeDetailsViewController: UIViewController {
    var volume: Book

    init(with volume: Book) { //TODO: convert to vm
        self.volume = volume
        super.init(nibName: nil, bundle: nil)
        title = volume.title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        view.backgroundColor = .white
    }

}
