//
//  ThemeCustomization.swift
//  ThemeKit
//
//  Created by Subo on 12/19/25.
//

import UIKit
import ThemeKit

// MARK: - Define

// 新增两个颜色
extension ThemeColorToken {
    static let demoCard = ThemeColorToken("demo.card")
    static let demoHighlight = ThemeColorToken("demo.highlight")
}

enum ThemeDemoThemeFactory {
    static let catalog: ThemeCatalog = {
        let base = ThemeCatalog.default

        let lightPalette = base.lightTheme.palette.applyingOverrides([
            .demoCard: UIColor(red: 0.85, green: 0.96, blue: 0.90, alpha: 1.0),
            .demoHighlight: UIColor(red: 0.12, green: 0.35, blue: 0.84, alpha: 1.0),
            .accent: UIColor(red: 0.70, green: 0.22, blue: 0.83, alpha: 1.0)    // 覆盖框架内部的原有的颜色
        ])

        let darkPalette = base.darkTheme.palette.applyingOverrides([
            .demoCard: UIColor(red: 0.26, green: 0.08, blue: 0.14, alpha: 1.0),
            .demoHighlight: UIColor(red: 0.00, green: 0.82, blue: 0.49, alpha: 1.0),
            .accent: UIColor(red: 0.98, green: 0.64, blue: 0.16, alpha: 1.0)    // 覆盖框架内部的原有的颜色
        ])

        let lightTheme = Theme(interfaceStyle: .light, palette: lightPalette)
        let darkTheme = Theme(interfaceStyle: .dark, palette: darkPalette)
        return ThemeCatalog(lightTheme: lightTheme, darkTheme: darkTheme)
    }()
}

// MARK: - Usage

// 封装对外的便捷调用
public extension UIColor {
    @objc class var themeDemoCard: UIColor { ThemeDynamicColor.color(for: .demoCard) }
    @objc class var themeDemoHighlight: UIColor { ThemeDynamicColor.color(for: .demoHighlight) }
}

#if canImport(SwiftUI)
import SwiftUI

extension Color {
    static var themeDemoCard: Color { theme(.demoCard) }
    static var themeDemoHighlight: Color { theme(.demoHighlight) }
}

#endif
