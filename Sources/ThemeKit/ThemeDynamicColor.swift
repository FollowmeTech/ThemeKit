//
//  ThemeDynamicColor.swift
//  ThemeKit
//
//  Created by Subo on 12/19/25.
//

import UIKit

/// Provides dynamic colors that automatically respond to system or manual theme changes.
@objcMembers
public final class ThemeDynamicColor: NSObject {
    public static func background() -> UIColor { color(for: .background) }
    public static func surface() -> UIColor { color(for: .surface) }
    public static func primaryText() -> UIColor { color(for: .primaryText) }
    public static func secondaryText() -> UIColor { color(for: .secondaryText) }
    public static func accent() -> UIColor { color(for: .accent) }
    public static func divider() -> UIColor { color(for: .divider) }

    // Build a dynamic UIColor that resolves via ThemeManager on each trait lookup.
    public static func color(for token: ThemeColorToken) -> UIColor {
        return UIColor { trait in
            let interfaceStyle: ThemeInterfaceStyle
            if trait.userInterfaceStyle == .unspecified {
                // Use ThemeManager when UIKit hasn't decided an explicit style.
                interfaceStyle = ThemeManager.shared.currentTheme.interfaceStyle
            } else {
                interfaceStyle = ThemeInterfaceStyle(userInterfaceStyle: trait.userInterfaceStyle)
            }
            let theme = ThemeManager.shared.theme(for: interfaceStyle)
            return theme.palette.color(for: token)
        }
    }

    @objc(colorNamed:)
    public static func color(named name: String) -> UIColor {
        return color(for: ThemeColorToken(name))
    }
}
