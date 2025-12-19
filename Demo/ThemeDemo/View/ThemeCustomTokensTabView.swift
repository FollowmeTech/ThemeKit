//
//  ThemeCustomTokensTabView.swift
//  ThemeKit
//
//  Created by Subo on 12/19/25.
//

import SwiftUI
import ThemeKit

struct ThemeCustomTokensTabView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("自定义 Token 预览")
                    .font(.title2.bold())
                    .foregroundColor(.themePrimaryText)

                Text("ThemeDemo 在应用层扩展了 ThemeColorToken，同时覆盖了内置 token（比如 accent）。")
                    .font(.subheadline)
                    .foregroundColor(.themeSecondaryText)

                overrideCard
                customTokenCard
            }
            .padding(20)
        }
        .background(Color.themeBackground.ignoresSafeArea())
    }

    private var overrideCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("覆盖原有 Token")
                .font(.headline)
                .foregroundColor(.themePrimaryText)

            Text("ThemeDemoThemeFactory 重写了 .accent，用来演示覆盖默认配置。")
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)

            HStack(spacing: 12) {
                tokenChip(title: "Accent", color: .themeAccent)
            }
        }
        .padding(16)
        .background(Color.themeSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.themeDivider, lineWidth: 1)
        )
    }

    private var customTokenCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("新增 Token")
                .font(.headline)
                .foregroundColor(.themePrimaryText)

            Text("通过 Color.theme(.demoCard) 读取扩展 token。")
                .font(.subheadline)
                .foregroundColor(.themeSecondaryText)

            HStack(spacing: 12) {
                tokenChip(title: "Card", color: .themeDemoCard)
                tokenChip(title: "Highlight", color: .themeDemoHighlight)
            }
        }
        .padding(16)
        .background(Color.themeSurface)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.themeDivider, lineWidth: 1)
        )
    }

    private func tokenChip(title: String, color: Color) -> some View {
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
