import UIKit
import ThemeKit

/// 第二个标签页：集中展示设置项，并将主题切换放入二级页面。
final class SettingsViewController: UITableViewController {

    private enum Section: Int, CaseIterable {
        case appearance
        case about

        var title: String {
            switch self {
            case .appearance:
                return "显示与外观"
            case .about:
                return "关于"
            }
        }
    }

    private enum AppearanceRow: Int, CaseIterable {
        case theme

        var title: String {
            switch self {
            case .theme:
                return "主题与配色"
            }
        }
    }

    private enum AboutRow: Int, CaseIterable {
        case version
    }

    private let cellIdentifier = "SettingsCell"

    init() {
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "设置"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.rowHeight = 52

        applyTheme()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .appearance:
            return AppearanceRow.allCases.count
        case .about:
            return AboutRow.allCases.count
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .value1, reuseIdentifier: cellIdentifier)
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        configure(cell: cell, for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .themeSurface
        cell.textLabel?.textColor = .themePrimaryText
        cell.detailTextLabel?.textColor = .themeSecondaryText
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .appearance:
            guard let row = AppearanceRow(rawValue: indexPath.row) else { return }
            switch row {
            case .theme:
                let controller = ThemeSelectionViewController()
                navigationController?.pushViewController(controller, animated: true)
            }
        case .about:
            presentAboutInformation()
        }
    }

    // MARK: - Private

    private func configure(cell: UITableViewCell, for indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .appearance:
            guard let row = AppearanceRow(rawValue: indexPath.row) else { return }
            switch row {
            case .theme:
                cell.textLabel?.text = row.title
                cell.detailTextLabel?.text = themeSelectionDescription()
            }
        case .about:
            cell.textLabel?.text = "版本"
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                cell.detailTextLabel?.text = "v\(version) (\(build))"
            } else {
                cell.detailTextLabel?.text = "开发中"
            }
            cell.accessoryType = .none
        }
    }

    private func themeSelectionDescription() -> String {
        switch ThemeManager.shared.selection {
        case .followSystem:
            return "跟随系统"
        case .light:
            return "浅色模式"
        case .dark:
            return "深色模式"
        }
    }

    private func presentAboutInformation() {
        let alert = UIAlertController(title: "ThemeDemo", message: "演示如何在 UIKit 中实现可切换主题结构，并融合 UITabBar 与二级设置页面。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default))
        present(alert, animated: true)
    }

    private func applyTheme() {
        view.backgroundColor = .themeBackground
        tableView.backgroundColor = .themeBackground
        tableView.separatorColor = .themeDivider
        tableView.tintColor = .themeAccent
    }
}
