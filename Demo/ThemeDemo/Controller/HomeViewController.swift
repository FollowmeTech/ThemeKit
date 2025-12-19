import UIKit
import ThemeKit

/// 首个标签页：概览主题效果并引导用户前往设置页面。
final class HomeViewController: UIViewController {

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.text = "Theme Demo"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "查看主题预览，并通过右上角按钮调整配色。"
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let previewCard = ThemeSurfaceView()

    private let previewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "当前主题概览"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let previewDetailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var changeThemeButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .large
        configuration.title = "调整主题"
        configuration.baseBackgroundColor = .themeAccent
        configuration.baseForegroundColor = .white

        let button = UIButton(configuration: configuration, primaryAction: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapChangeTheme), for: .touchUpInside)
        return button
    }()

    private var themeObservation: NSObjectProtocol?

    deinit {
        if let token = themeObservation {
            NotificationCenter.default.removeObserver(token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "概览"
        navigationController?.navigationBar.prefersLargeTitles = true
        configureLayout()
        applyTheme()
        updatePreviewDescription()
        bindThemeObservation()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "主题", style: .plain, target: self, action: #selector(didTapChangeTheme))
    }

    private func configureLayout() {
        previewCard.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headlineLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(previewCard)
        view.addSubview(changeThemeButton)

        previewCard.addSubview(previewTitleLabel)
        previewCard.addSubview(previewDetailLabel)

        NSLayoutConstraint.activate([
            headlineLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            headlineLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headlineLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            subtitleLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 16),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            previewCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            previewCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            previewCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            previewTitleLabel.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 20),
            previewTitleLabel.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 20),
            previewTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: previewCard.trailingAnchor, constant: -20),

            previewDetailLabel.topAnchor.constraint(equalTo: previewTitleLabel.bottomAnchor, constant: 12),
            previewDetailLabel.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 20),
            previewDetailLabel.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -20),
            previewDetailLabel.bottomAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: -20),

            changeThemeButton.topAnchor.constraint(greaterThanOrEqualTo: previewCard.bottomAnchor, constant: 40),
            changeThemeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            changeThemeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            changeThemeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32),
            changeThemeButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func applyTheme() {
        view.backgroundColor = .themeBackground
        view.tintColor = .themeAccent
        headlineLabel.textColor = .themePrimaryText
        subtitleLabel.textColor = .themeSecondaryText
        previewTitleLabel.textColor = .themePrimaryText
        previewDetailLabel.textColor = .themeSecondaryText
        previewCard.layer.shadowColor = UIColor.themeAccent.withAlphaComponent(0.05).cgColor
        previewCard.layer.shadowOpacity = 1
        previewCard.layer.shadowRadius = 20
        previewCard.layer.shadowOffset = CGSize(width: 0, height: 12)
        var configuration = changeThemeButton.configuration ?? UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .themeAccent
        configuration.baseForegroundColor = .white
        changeThemeButton.configuration = configuration
    }

    private func bindThemeObservation() {
        themeObservation = NotificationCenter.default.addObserver(forName: ThemeManager.themeDidChangeNotification,
                                                                   object: nil,
                                                                   queue: .main) { [weak self] _ in
//            self?.applyTheme()
            self?.updatePreviewDescription()
        }
    }

    private func updatePreviewDescription() {
        let selection = ThemeManager.shared.selection
        let modeDescription: String
        switch selection {
        case .followSystem:
            modeDescription = "跟随系统"
        case .light:
            modeDescription = "浅色模式"
        case .dark:
            modeDescription = "深色模式"
        }
        let interfaceStyle = ThemeManager.shared.currentTheme.interfaceStyle
        let brightnessDescription = interfaceStyle == .dark ? "深色背景，更适合在低光环境下使用。" : "浅色背景，强调内容可读性。"
        previewDetailLabel.text = """
        当前模式：\(modeDescription)
        \(brightnessDescription)
        调整后 Tab 与按钮主色会一并刷新。
        """
    }

    @objc private func didTapChangeTheme() {
        let controller = ThemeSelectionViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
