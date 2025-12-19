//
//  ThemeManager.swift
//  ThemeKit
//
//  Created by Subo on 12/19/25.
//

import UIKit

/// Central coordinator that keeps the app-wide theme in sync with user preference and system state.
@objcMembers
public final class ThemeManager: NSObject {
    public static let shared = ThemeManager()

    /// Posted whenever the effective theme changes. `userInfo[themeUserInfoKey]` contains the active `Theme`.
    public static let themeDidChangeNotification = Notification.Name("ThemeDidChangedNotification")
    /// Posted whenever the user selection changes. `userInfo[selectionUserInfoKey]` contains the raw value.
    public static let selectionDidChangeNotification = Notification.Name("ThemeSelectionDidChangeNotification")

    /// String constants exported for Objective-C callers to subscribe to notifications.
    @objc public static let themeDidChangeNotificationName = "ThemeDidChangedNotification"
    @objc public static let selectionDidChangeNotificationName = "ThemeSelectionDidChangeNotification"
    @objc public static let themeUserInfoKey = "ThemeManagerActiveThemeKey"
    @objc public static let selectionUserInfoKey = "ThemeManagerSelectionKey"

    private let preferenceStore = ThemePreferenceStore()
    // Weak storage avoids retaining windows beyond their lifecycle.
    private var windows = NSHashTable<UIWindow>.weakObjects()
    private var catalog: ThemeCatalog

    public private(set) var selection: ThemeSelection {
        didSet {
            guard oldValue != selection else { return }
            preferenceStore.store(selection)
        }
    }

    private var systemInterfaceStyle: ThemeInterfaceStyle {
        didSet {
            guard oldValue != systemInterfaceStyle else { return }
            if selection == .followSystem {
                resolveThemeAndApply()
            }
        }
    }

    public private(set) var currentTheme: Theme

    private override init() {
        let storedSelection = ThemePreferenceStore().loadSelection() ?? .followSystem
        let systemStyle = ThemeInterfaceStyle(userInterfaceStyle: UIScreen.main.traitCollection.userInterfaceStyle)
        let catalog = ThemeCatalog.default
        self.catalog = catalog
        self.selection = storedSelection
        self.systemInterfaceStyle = systemStyle
        self.currentTheme = catalog.theme(for: ThemeManager.resolveInterfaceStyle(selection: storedSelection, systemInterfaceStyle: systemStyle))
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleApplicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    /// Swap the catalog (e.g. inject brand colors) and immediately propagate.
    public func configure(with catalog: ThemeCatalog) {
        assertMainThread()
        self.catalog = catalog
        resolveThemeAndApply()
    }

    /// Register a window for automatic interface-style updates.
    public func register(window: UIWindow) {
        assertMainThread()
        windows.add(window)
        updateSystemInterfaceStyleIfNeeded(window.traitCollection)
        window.tintColor = .themeAccent
        applyInterfaceStyle(to: window)
    }

    /// Selected option persistence entry point for callers (Objective-C friendly).
    public func selectTheme(_ selection: ThemeSelection) {
        assertMainThread()
        guard self.selection != selection else { return }
        self.selection = selection
        NotificationCenter.default.post(name: ThemeManager.selectionDidChangeNotification,
                                        object: self,
                                        userInfo: [ThemeManager.selectionUserInfoKey: selection.rawValue])
        resolveThemeAndApply()
    }

    /// Call from `SceneDelegate` / window subclasses when the system style changes.
    public func updateSystemInterfaceStyleIfNeeded(_ traitCollection: UITraitCollection) {
        assertMainThread()
        let style = ThemeInterfaceStyle(userInterfaceStyle: traitCollection.userInterfaceStyle)
        if style != systemInterfaceStyle {
            systemInterfaceStyle = style
        }
    }

    /// Get the catalog-defined theme for a particular interface style.
    public func theme(for style: ThemeInterfaceStyle) -> Theme {
        return catalog.theme(for: style)
    }

    /// Shared helper for UIKit callers that need the current interface style.
    public func effectiveInterfaceStyle() -> ThemeInterfaceStyle {
        return ThemeManager.resolveInterfaceStyle(selection: selection, systemInterfaceStyle: systemInterfaceStyle)
    }

    @objc private func handleApplicationDidBecomeActive() {
        assertMainThread()
        updateSystemInterfaceStyleIfNeeded(UIScreen.main.traitCollection)
    }

    // Resolve selection + system style to a concrete theme, then broadcast updates.
    private func resolveThemeAndApply() {
        let targetStyle = ThemeManager.resolveInterfaceStyle(selection: selection, systemInterfaceStyle: systemInterfaceStyle)
        let resolvedTheme = catalog.theme(for: targetStyle)
        applyResolvedTheme(resolvedTheme)
    }

    private func applyResolvedTheme(_ theme: Theme) {
        let previousTheme = currentTheme
        let didChange = previousTheme !== theme || previousTheme.interfaceStyle != theme.interfaceStyle
        currentTheme = theme
        for window in windows.allObjects {
            window.tintColor = .themeAccent
            applyInterfaceStyle(to: window)
        }
        if didChange {
            NotificationCenter.default.post(name: ThemeManager.themeDidChangeNotification,
                                            object: self,
                                            userInfo: [ThemeManager.themeUserInfoKey: theme])
        }
    }

    private func applyInterfaceStyle(to window: UIWindow) {
        switch selection {
        case .followSystem:
            window.overrideUserInterfaceStyle = .unspecified
        case .light, .dark:
            window.overrideUserInterfaceStyle = effectiveInterfaceStyle().userInterfaceStyle
        }
    }

    private static func resolveInterfaceStyle(selection: ThemeSelection, systemInterfaceStyle: ThemeInterfaceStyle) -> ThemeInterfaceStyle {
        switch selection {
        case .followSystem:
            return systemInterfaceStyle
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    private func assertMainThread() {
        assert(Thread.isMainThread, "ThemeManager APIs must be invoked on the main thread.")
    }
}

/// Simple persistence helper that survives app restarts via `UserDefaults`.
private final class ThemePreferenceStore {
    private let defaults: UserDefaults
    private let key = "com.themedemo.selection"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func loadSelection() -> ThemeSelection? {
        let value = defaults.integer(forKey: key)
        return ThemeSelection(rawValue: value)
    }

    func store(_ selection: ThemeSelection) {
        defaults.set(selection.rawValue, forKey: key)
    }
}
