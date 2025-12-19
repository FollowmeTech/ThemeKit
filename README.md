# ThemeKit

<div align="center">  
  <img src="https://img.shields.io/badge/iOS-13.0%2B-blue" alt="iOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/SwiftUI%2BUIKit-hotpink" alt="SwiftUI + UIKit">
</div>

<br />
> 🇨🇳 Looking for the Chinese README? See [README_CN.md](./README_CN.md).

An iOS theme framework that supports Objective-C, Swift, and SwiftUI simultaneously.

---

## Features

- Centralized theme manager with system-following or manual light/dark selection.
- Dynamic UIKit colors via `UIColor` helpers and `ThemeDynamicColor`.
- SwiftUI bridge with `Color` helpers and `ThemeObserver`.
- Customizable palettes and tokens with fallback support.
- Demo app showcasing UIKit + SwiftUI usage.

## Requirements

- iOS 13+
- Swift tools 5.9 (Xcode 16+)

## Installation (Swift Package Manager)

### Xcode

1. File > Add Package Dependencies...
2. Enter the URL: `https://github.com/FollowmeTech/ThemeKit.git`
3. Add `ThemeKit` to your target.

### Package.swift

```swift
.package(url: "https://github.com/FollowmeTech/ThemeKit.git", from: "1.0.0")
```

Then add the product:

```swift
.product(name: "ThemeKit", package: "ThemeKit")
```

## Quick Start (UIKit)

Configure the theme manager at app launch (SceneDelegate or AppDelegate):

```swift
import ThemeKit

ThemeManager.shared.updateSystemInterfaceStyleIfNeeded(windowScene.traitCollection)
ThemeManager.shared.configure(with: ThemeCatalog.default)
ThemeManager.shared.register(window: window)
```

Use theme colors:

```swift
view.backgroundColor = .themeBackground
label.textColor = .themePrimaryText
button.tintColor = .themeAccent
```

Switch themes:

```swift
ThemeManager.shared.selectTheme(.dark) // .light / .followSystem
```

## SwiftUI

Use `ThemeObserver` to trigger view updates when the selection changes:

```swift
import ThemeKit

@StateObject private var themeObserver = ThemeObserver()

var body: some View {
    VStack(spacing: 12) {
        Text("ThemeKit")
            .foregroundColor(.themePrimaryText)
        Text(themeObserver.selection == .dark ? "Dark" : "Light")
            .foregroundColor(.themeSecondaryText)
    }
    .padding()
    .background(Color.themeBackground)
}
```

## Objective-C

```objc
@import ThemeKit;

[[ThemeManager shared] selectTheme:ThemeSelectionDark];
self.view.backgroundColor = [UIColor themeBackground];
self.label.textColor = [UIColor themePrimaryText];
```

## Custom Themes & Tokens

Extend `ThemeColorToken`, override palettes, and reconfigure the manager:

```swift
extension ThemeColorToken {
    static let demoCard = ThemeColorToken("demo.card")
}

let base = ThemeCatalog.default
let lightPalette = base.lightTheme.palette.applyingOverrides([
    .demoCard: UIColor(red: 0.85, green: 0.96, blue: 0.90, alpha: 1.0),
    .accent: .systemPink
])
let darkPalette = base.darkTheme.palette.applyingOverrides([
    .demoCard: UIColor(red: 0.26, green: 0.08, blue: 0.14, alpha: 1.0),
    .accent: .systemOrange
])

let catalog = ThemeCatalog(
    lightTheme: Theme(interfaceStyle: .light, palette: lightPalette),
    darkTheme: Theme(interfaceStyle: .dark, palette: darkPalette)
)

ThemeManager.shared.configure(with: catalog)
```

## Demo App

Open the sample app and run the `ThemeDemo` scheme:

```sh
open Demo/ThemeDemo.xcodeproj
```

## Tests

```sh
swift test
```

## License

MIT. See `LICENSE`.
