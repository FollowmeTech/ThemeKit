# ThemeKit

<div align="center">  
  <img src="https://img.shields.io/badge/iOS-13.0%2B-blue" alt="iOS 13.0+">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/SwiftUI%2BUIKit-hotpink" alt="SwiftUI + UIKit">
</div>

<br />
一个同时支持 Objective-C、Swift 和 SwiftUI 的 iOS 主题框架。

---

## 特性

- 统一的主题管理器，支持跟随系统或手动选择浅色/深色。
- UIKit 动态颜色封装（`UIColor` 便捷属性与 `ThemeDynamicColor`）。
- SwiftUI 桥接（`Color` 便捷属性与 `ThemeObserver`）。
- 可扩展的颜色 Token 与调色板覆盖机制。
- Demo 工程演示 UIKit + SwiftUI 的组合使用。

## 系统要求

- iOS 13+
- Swift tools 5.9（Xcode 16+）

## 安装（Swift Package Manager）

### Xcode

1. File > Add Package Dependencies...
2. 输入地址：`https://github.com/FollowmeTech/ThemeKit.git`
3. 将 `ThemeKit` 添加到目标工程。

### Package.swift

```swift
.package(url: "https://github.com/FollowmeTech/ThemeKit.git", from: "1.0.0")
```

然后添加产品依赖：

```swift
.product(name: "ThemeKit", package: "ThemeKit")
```

## 快速开始（UIKit）

在应用启动时配置主题（SceneDelegate 或 AppDelegate）：

```swift
import ThemeKit

ThemeManager.shared.updateSystemInterfaceStyleIfNeeded(windowScene.traitCollection)
ThemeManager.shared.configure(with: ThemeCatalog.default)
ThemeManager.shared.register(window: window)
```

使用主题颜色：

```swift
view.backgroundColor = .themeBackground
label.textColor = .themePrimaryText
button.tintColor = .themeAccent
```

切换主题：

```swift
ThemeManager.shared.selectTheme(.dark) // .light / .followSystem
```

## SwiftUI

使用 `ThemeObserver` 在主题切换时触发视图刷新：

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

## 自定义主题与 Token

扩展 `ThemeColorToken`，覆盖调色板并重新配置：

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

## Demo 示例

打开示例工程并运行 `ThemeDemo`：

```sh
open Demo/ThemeDemo.xcodeproj
```

## 测试

```sh
swift test
```

## 许可证

MIT。详见 `LICENSE`。
