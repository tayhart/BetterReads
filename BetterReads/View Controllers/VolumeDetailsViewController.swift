//
//  VolumeDetailsViewController.swift
//  BetterReads
//
//  Created by Taylor Hartman on 7/4/22.
//

import UIKit

final class VolumeDetailsViewController: UIViewController {

    let testText = "Hello Volume Controller"

    override func viewDidLoad() {
        let testLabel = UILabel()
        testLabel.text = testText
        view.addSubview(testLabel)
    }

}
