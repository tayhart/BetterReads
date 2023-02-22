//
//  ColorUtil.swift
//  BetterReads
//
//  Created by Taylor Hartman on 2/19/23.
//

import UIKit

extension UIColor {
    static let primaryBackgroundColor = moonstoneBlue
    static let primaryAccentColor = richLavendar
    static let secondaryAccentColor = pistachio

    static let ivory = UIColor(r: 255.0, g: 255.0, b: 240.0)
    static let cream = UIColor(r: 255, g: 253, b: 208)
    static let lavendarBlue = UIColor(r: 208, g: 210, b: 255)
    static let pistachio = UIColor(r: 147, g: 197, b: 114)
    static let richLavendar = UIColor(r: 164, g: 114, b: 197)
    static let moonstoneBlue = UIColor(r: 114, g: 189, b: 197)
    static let oldRose = UIColor(r: 197, g: 123, b: 114)

    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}
