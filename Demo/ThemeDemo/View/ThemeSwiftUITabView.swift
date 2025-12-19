import SwiftUI
import ThemeKit

struct ThemeSwiftUITabRootView: View {
    var body: some View {
        ThemeSwiftUITabContentView()
    }
}

private struct ThemeSwiftUITabContentView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("SwiftUI 主题预览")
                    .font(.title2.bold())
                    .foregroundColor(.themePrimaryText)

                paletteCard
            }
            .padding(20)
        }
        .background(Color.themeBackground.ignoresSafeArea())
    }

    private var paletteCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("颜色样例")
                .font(.headline)
                .foregroundColor(.themePrimaryText)

            Text("这些颜色来自 ThemeKit 的 SwiftUI 桥接。")
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)

            HStack(spacing: 12) {
                colorChip(title: "Background", color: .themeBackground)
                colorChip(title: "Surface", color: .themeSurface)
                colorChip(title: "Accent", color: .themeAccent)
            }
        }
        .padding(16)
        .background(Color.themeSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.themeDivider, lineWidth: 1)
        )
    }

    private func colorChip(title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 28, height: 28)
            Text(title)
                .font(.caption)
                .foregroundColor(.themeSecondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}
