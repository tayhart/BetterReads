//
//  FontUtil.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/19/23.
//

import UIKit

enum TextType {
    case body
    case headerSmall
    case headerMedium
    case headerBig
    case subHeader
}

extension UILabel {
    func apply(type: TextType) {
        let size: CGFloat = {
            switch type {
                case .body:
                    return 12
                case .headerSmall, .subHeader:
                    return 14
                case .headerMedium:
                    return 16
                case .headerBig:
                    return 18
            }
        }()
        let fontName: String = {
            switch type {
                case .body:
                    return "Optima"
                case .headerSmall, .headerMedium, .headerBig:
                    return "Optima-bold"
                case .subHeader:
                    return "Optima-italic"
            }
        }()
        font = UIFont(name: fontName, size: size)
    }
}

extension UITextView {
    func apply(type: TextType) {
        let size: CGFloat = {
            switch type {
                case .body:
                    return 12
                case .headerSmall, .subHeader:
                    return 14
                case .headerMedium:
                    return 16
                case .headerBig:
                    return 18
            }
        }()
        let fontName: String = {
            switch type {
                case .body:
                    return "Optima"
                case .headerSmall, .headerMedium, .headerBig:
                    return "Optima-bold"
                case .subHeader:
                    return "Optima-italic"
            }
        }()
        font = UIFont(name: fontName, size: size)
    }
}
