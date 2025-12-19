//
//  ThemeKitTests.swift
//  ThemeKit
//
//  Created by Subo on 12/19/25.
//

import XCTest
import UIKit
@testable import ThemeKit

final class ThemeKitTests: XCTestCase {
    func testDefaultCatalogProvidesLightAndDarkThemes() {
        let catalog = ThemeCatalog.default
        XCTAssertEqual(catalog.theme(for: .light).interfaceStyle, .light)
        XCTAssertEqual(catalog.theme(for: .dark).interfaceStyle, .dark)
    }

    func testPaletteOverridesFallbackToBaseColors() {
        let base = ThemePalette(backgroundColor: .red,
                                surfaceBackgroundColor: .green,
                                primaryTextColor: .blue,
                                secondaryTextColor: .yellow,
                                accentColor: .purple,
                                dividerColor: .brown)
        let customToken = ThemeColorToken("demo.custom")
        let override = base.applyingOverrides([customToken: .black])

        XCTAssertTrue(override.color(for: customToken).isEqual(UIColor.black))
        XCTAssertTrue(override.backgroundColor.isEqual(UIColor.red))
    }
}
