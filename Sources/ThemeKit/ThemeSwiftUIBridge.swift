//
//  ThemeSwiftUIBridge.swift
//  ThemeKit
//
//  Created by Subo on 12/19/25.
//

#if canImport(SwiftUI)
import SwiftUI
import Combine

/// Observable theme state for SwiftUI views that need more than colors.
@MainActor
public final class ThemeObserver: ObservableObject {
    @Published public private(set) var theme: Theme
    @Published public private(set) var selection: ThemeSelection

    private var themeToken: NSObjectProtocol?
    private var selectionToken: NSObjectProtocol?
    private let manager: ThemeManager

    public init(manager: ThemeManager = .shared) {
        self.manager = manager
        self.theme = manager.currentTheme
        self.selection = manager.selection

        themeToken = NotificationCenter.default.addObserver(forName: ThemeManager.themeDidChangeNotification,
                                                            object: nil,
                                                            queue: .main) { [weak self] notification in
            guard let theme = notification.userInfo?[ThemeManager.themeUserInfoKey] as? Theme else { return }
            self?.theme = theme
            self?.selection = ThemeManager.shared.selection
        }

        selectionToken = NotificationCenter.default.addObserver(forName: ThemeManager.selectionDidChangeNotification,
                                                                object: nil,
                                                                queue: .main) { [weak self] notification in
            guard let rawValue = notification.userInfo?[ThemeManager.selectionUserInfoKey] as? Int,
                  let selection = ThemeSelection(rawValue: rawValue) else { return }
            self?.selection = selection
        }
    }

    deinit {
        if let token = themeToken {
            NotificationCenter.default.removeObserver(token)
        }
        if let token = selectionToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
}

/// SwiftUI bridge that mirrors ThemeDynamicColor tokens.
public extension Color {
    static func theme(_ token: ThemeColorToken) -> Color { Color(ThemeDynamicColor.color(for: token)) }

    static var themeBackground: Color { theme(.background) }
    static var themeSurface: Color { theme(.surface) }
    static var themePrimaryText: Color { theme(.primaryText) }
    static var themeSecondaryText: Color { theme(.secondaryText) }
    static var themeAccent: Color { theme(.accent) }
    static var themeDivider: Color { theme(.divider) }
}
#endif
