//
//  ThemeDefinition.swift
//  ThemeKit
//
//  Created by Subo on 12/19/25.
//

import UIKit

/// Represents the way a theme is chosen within the app.
/// Raw values are persisted; keep them stable.
@objc public enum ThemeSelection: Int {
    case followSystem = 0
    case light = 1
    case dark = 2
}

/// Captures the concrete interface style a theme targets.
@objc public enum ThemeInterfaceStyle: Int {
    case light = 0
    case dark = 1

    init(userInterfaceStyle: UIUserInterfaceStyle) {
        switch userInterfaceStyle {
        case .dark:
            self = .dark
        default:
            self = .light
        }
    }

    /// Map to the UIKit style for use with `overrideUserInterfaceStyle`.
    public var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

/// Shared identifiers for theme color tokens across UIKit and SwiftUI.
/// Extend in your app target to define custom tokens.
public struct ThemeColorToken: Hashable, RawRepresentable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public static let background = ThemeColorToken("background")
    public static let surface = ThemeColorToken("surface")
    public static let primaryText = ThemeColorToken("primaryText")
    public static let secondaryText = ThemeColorToken("secondaryText")
    public static let accent = ThemeColorToken("accent")
    public static let divider = ThemeColorToken("divider")
}

/// Concrete color tokens used to drive UIKit components.
@objcMembers
public final class ThemePalette: NSObject {
    private let colors: [ThemeColorToken: UIColor]
    private let fallback: ThemePalette?

    public init(colors: [ThemeColorToken: UIColor], fallback: ThemePalette? = nil) {
        self.colors = colors
        self.fallback = fallback
        if fallback == nil {
            let required: [ThemeColorToken] = [.background, .surface, .primaryText, .secondaryText, .accent, .divider]
            let missing = required.filter { colors[$0] == nil }
            assert(missing.isEmpty, "ThemePalette missing required tokens: \(missing.map(\.rawValue).joined(separator: ", "))")
        }
    }

    public convenience init(backgroundColor: UIColor,
                            surfaceBackgroundColor: UIColor,
                            primaryTextColor: UIColor,
                            secondaryTextColor: UIColor,
                            accentColor: UIColor,
                            dividerColor: UIColor) {
        self.init(colors: [
            .background: backgroundColor,
            .surface: surfaceBackgroundColor,
            .primaryText: primaryTextColor,
            .secondaryText: secondaryTextColor,
            .accent: accentColor,
            .divider: dividerColor
        ])
    }

    @objc(initWithColorsByName:fallback:)
    public convenience init(colorsByName: [String: UIColor], fallback: ThemePalette? = nil) {
        let tokens = Dictionary(uniqueKeysWithValues: colorsByName.map { (ThemeColorToken($0.key), $0.value) })
        self.init(colors: tokens, fallback: fallback)
    }

    public var backgroundColor: UIColor { color(for: .background) }
    public var surfaceBackgroundColor: UIColor { color(for: .surface) }
    public var primaryTextColor: UIColor { color(for: .primaryText) }
    public var secondaryTextColor: UIColor { color(for: .secondaryText) }
    public var accentColor: UIColor { color(for: .accent) }
    public var dividerColor: UIColor { color(for: .divider) }

    /// Centralized mapping so new tokens only need to be added in one place.
    public func color(for token: ThemeColorToken) -> UIColor {
        if let color = colors[token] {
            return color
        }
        if let fallback = fallback {
            return fallback.color(for: token)
        }
        assertionFailure("Missing color for token: \(token.rawValue)")
        return .clear
    }

    @objc(colorNamed:)
    public func color(named name: String) -> UIColor {
        return color(for: ThemeColorToken(name))
    }

    /// Create a palette that falls back to the current palette for unresolved tokens.
    public func applyingOverrides(_ overrides: [ThemeColorToken: UIColor]) -> ThemePalette {
        return ThemePalette(colors: overrides, fallback: self)
    }

    @objc(applyingOverridesByName:)
    public func applyingOverridesByName(_ overrides: [String: UIColor]) -> ThemePalette {
        let tokens = Dictionary(uniqueKeysWithValues: overrides.map { (ThemeColorToken($0.key), $0.value) })
        return applyingOverrides(tokens)
    }
}

/// High level theme describing the target interface style and palette.
@objcMembers
public final class Theme: NSObject {
    public let interfaceStyle: ThemeInterfaceStyle
    public let palette: ThemePalette

    public init(interfaceStyle: ThemeInterfaceStyle, palette: ThemePalette) {
        self.interfaceStyle = interfaceStyle
        self.palette = palette
    }

    /// Built-in light theme.
    public static let standardLight = Theme(
        interfaceStyle: .light,
        palette: ThemePalette(
            backgroundColor: .systemBackground,
            surfaceBackgroundColor: .secondarySystemBackground,
            primaryTextColor: .label,
            secondaryTextColor: .secondaryLabel,
            accentColor: .systemBlue,
            dividerColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.2) : UIColor(white: 0.0, alpha: 0.1)
            }
        )
    )

    /// Built-in dark theme.
    public static let standardDark = Theme(
        interfaceStyle: .dark,
        palette: ThemePalette(
            backgroundColor: UIColor(red: 0.07, green: 0.07, blue: 0.11, alpha: 1.0),
            surfaceBackgroundColor: UIColor(red: 0.12, green: 0.12, blue: 0.17, alpha: 1.0),
            primaryTextColor: .white,
            secondaryTextColor: UIColor(white: 0.85, alpha: 1.0),
            accentColor: .systemTeal,
            dividerColor: UIColor(white: 1.0, alpha: 0.15)
        )
    )
}

/// Container describes the light/dark pairing that may be swapped or replaced later.
@objcMembers
public final class ThemeCatalog: NSObject {
    public let lightTheme: Theme
    public let darkTheme: Theme

    public init(lightTheme: Theme, darkTheme: Theme) {
        self.lightTheme = lightTheme
        self.darkTheme = darkTheme
    }

    public func theme(for style: ThemeInterfaceStyle) -> Theme {
        switch style {
        case .light:
            return lightTheme
        case .dark:
            return darkTheme
        }
    }

    /// Default catalog shipping with the demo.
    public static let `default` = ThemeCatalog(lightTheme: .standardLight, darkTheme: .standardDark)
}
