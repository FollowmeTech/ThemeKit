//
//  SceneDelegate.swift
//  ThemeDemo
//
//  Created by Subo on 9/29/25.
//

import UIKit
import ThemeKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = RootTabBarController()

        ThemeManager.shared.updateSystemInterfaceStyleIfNeeded(windowScene.traitCollection)
        ThemeManager.shared.configure(with: ThemeDemoThemeFactory.catalog)
        ThemeManager.shared.register(window: window)

        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        guard let window = window else { return }
        ThemeManager.shared.updateSystemInterfaceStyleIfNeeded(window.traitCollection)
    }

    func windowScene(_ windowScene: UIWindowScene,
                     didUpdate previousCoordinateSpace: UICoordinateSpace,
                     interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation,
                     traitCollection previousTraitCollection: UITraitCollection) {
        ThemeManager.shared.updateSystemInterfaceStyleIfNeeded(windowScene.traitCollection)
    }
}
