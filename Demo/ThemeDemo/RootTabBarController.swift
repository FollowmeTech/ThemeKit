import UIKit
import SwiftUI
import ThemeKit

/// 应用根容器：提供 UITabBarController 结构，并在主题变化时刷新样式。
final class RootTabBarController: UITabBarController {

    private var themeObservation: NSObjectProtocol?

    deinit {
        if let token = themeObservation {
            NotificationCenter.default.removeObserver(token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewControllers()
        applyTheme()
        bindThemeObservation()
    }

    private func configureViewControllers() {
        let home = HomeViewController()
        let homeNavigation = UINavigationController(rootViewController: home)
        homeNavigation.tabBarItem = UITabBarItem(title: "概览",
                                                 image: UIImage(systemName: "paintpalette"),
                                                 selectedImage: UIImage(systemName: "paintpalette.fill"))

        let customTokensTab = UIHostingController(rootView: ThemeCustomTokensTabView())
        customTokensTab.title = "扩展"
        let customTokensNavigation = UINavigationController(rootViewController: customTokensTab)
        customTokensNavigation.tabBarItem = UITabBarItem(title: "扩展",
                                                         image: UIImage(systemName: "paintbrush"),
                                                         selectedImage: UIImage(systemName: "paintbrush.fill"))

        let swiftUITab = UIHostingController(rootView: ThemeSwiftUITabRootView())
        swiftUITab.title = "SwiftUI"
        let swiftUINavigation = UINavigationController(rootViewController: swiftUITab)
        swiftUINavigation.tabBarItem = UITabBarItem(title: "SwiftUI",
                                                    image: UIImage(systemName: "sparkles"),
                                                    selectedImage: UIImage(systemName: "sparkles"))

        let settings = SettingsViewController()
        let settingsNavigation = UINavigationController(rootViewController: settings)
        settingsNavigation.tabBarItem = UITabBarItem(title: "设置",
                                                     image: UIImage(systemName: "gearshape"),
                                                     selectedImage: UIImage(systemName: "gearshape.fill"))

        viewControllers = [homeNavigation, customTokensNavigation, swiftUINavigation, settingsNavigation]
    }

    private func applyTheme(force: Bool = false) {
        tabBar.tintColor = .themeAccent
        tabBar.unselectedItemTintColor = .themeSecondaryText

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .themeSurface
        appearance.shadowColor = .themeDivider
        
        if #available(iOS 26.0, *) {
            appearance.backgroundEffect = UIAccessibility.isReduceTransparencyEnabled ? nil : UIBlurEffect(style: .systemThinMaterial)
            appearance.backgroundColor = UIAccessibility.isReduceTransparencyEnabled
                ? .themeSurface
                : .themeSurface.withAlphaComponent(0.92)
            appearance.shadowColor = .themeDivider.withAlphaComponent(0.45)
        }

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }

        let navigationAppearance = UINavigationBarAppearance()
        navigationAppearance.configureWithOpaqueBackground()
        navigationAppearance.backgroundColor = .themeSurface
        navigationAppearance.titleTextAttributes = [.foregroundColor: UIColor.themePrimaryText]
        navigationAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.themePrimaryText]

        viewControllers?.forEach { controller in
            guard let navigation = (controller as? UINavigationController) else { return }
            navigation.navigationBar.tintColor = .themeAccent
            navigation.navigationBar.standardAppearance = navigationAppearance
            navigation.navigationBar.compactAppearance = navigationAppearance
            navigation.navigationBar.scrollEdgeAppearance = navigationAppearance
            
            if force {
                navigation.navigationBar.setNeedsLayout()
            }
        }
        
        UINavigationBar.appearance().tintColor = .themeAccent
        UINavigationBar.appearance().standardAppearance = navigationAppearance
        UINavigationBar.appearance().compactAppearance = navigationAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationAppearance
        
        UIApplication.shared.connectedScenes.forEach { scene in
            if let windowScene = scene as? UIWindowScene {
                windowScene.windows.forEach { window in
                    window.overrideUserInterfaceStyle = ThemeManager.shared.currentTheme.interfaceStyle == .light ? UIUserInterfaceStyle.light : UIUserInterfaceStyle.dark
                    
                    if force {
                        window.setNeedsLayout()
                        window.layoutIfNeeded()
                    }
                }
            }
        }
        
        if force {
            tabBar.setNeedsLayout()
            tabBar.layoutIfNeeded()
        }
    }

    private func bindThemeObservation() {
        themeObservation = NotificationCenter.default.addObserver(forName: ThemeManager.themeDidChangeNotification,
                                                                   object: nil,
                                                                   queue: .main) { [weak self] _ in
            self?.applyTheme(force: true)
        }
    }
}
