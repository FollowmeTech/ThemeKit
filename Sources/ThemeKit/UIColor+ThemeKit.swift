//
//  UIColor+ThemeKit.swift
//  ThemeKit
//
//  Created by Subo on 12/19/25.
//

import UIKit

/// ObjC-callable UIColor tokens that forward to ThemeDynamicColor.
public extension UIColor {
    @objc class var themeBackground: UIColor { ThemeDynamicColor.color(for: .background) }
    @objc class var themeSurface: UIColor { ThemeDynamicColor.color(for: .surface) }
    @objc class var themePrimaryText: UIColor { ThemeDynamicColor.color(for: .primaryText) }
    @objc class var themeSecondaryText: UIColor { ThemeDynamicColor.color(for: .secondaryText) }
    @objc class var themeAccent: UIColor { ThemeDynamicColor.color(for: .accent) }
    @objc class var themeDivider: UIColor { ThemeDynamicColor.color(for: .divider) }

    @objc(themeColorNamed:)
    class func themeColor(named name: String) -> UIColor {
        return ThemeDynamicColor.color(named: name)
    }
}
