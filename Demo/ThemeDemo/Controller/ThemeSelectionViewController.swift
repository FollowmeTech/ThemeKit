//
//  ThemeSelectionViewController.swift
//  ThemeDemo
//
//  Created by Subo on 9/29/25.
//

import UIKit
import ThemeKit

/// 二级页面：负责让用户选择主题模式并实时预览效果。
@objc(ViewController)
final class ThemeSelectionViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "主题模式"
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "选择以下任一模式后，全局界面会即时更新。"
        label.numberOfLines = 0
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var themeOptionsControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["跟随系统", "浅色", "深色"])
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(handleThemeSelection(_:)), for: .valueChanged)
        return control
    }()

    private let cardView: ThemeSurfaceView = {
        let view = ThemeSurfaceView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let cardTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "当前主题"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let cardSubtitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "此区域模拟业务界面，实时展示主题颜色变化。"
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 10
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "feedback")?.withRenderingMode(.alwaysTemplate)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .themeAccent
        return imageView
    }()
    
    private let button: UIButton = {
       let button = UIButton()
        button.tintColor = .themeAccent
        button.backgroundColor = .themeSurface
        button.setTitleColor(.themePrimaryText, for: .normal)
        button.setImage(UIImage(named: "chat")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitle("Chat", for: .normal)
        
        return button
    }()

    private var selectionObserver: NSObjectProtocol?

    deinit {
        if let token = selectionObserver {
            NotificationCenter.default.removeObserver(token)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "主题设置"
        navigationItem.largeTitleDisplayMode = .never
        setupLayout()
        applyThemeTokens()
        bindObservers()
        configureInitialState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCardShadow()
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(themeOptionsControl)
        view.addSubview(cardView)
        cardView.addSubview(cardTitleLabel)
        cardView.addSubview(cardSubtitleLabel)
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(button)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            themeOptionsControl.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            themeOptionsControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            themeOptionsControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            cardView.topAnchor.constraint(equalTo: themeOptionsControl.bottomAnchor, constant: 32),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 160),

            cardTitleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            cardTitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            cardTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: cardView.trailingAnchor, constant: -20),

            cardSubtitleLabel.topAnchor.constraint(equalTo: cardTitleLabel.bottomAnchor, constant: 12),
            cardSubtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            cardSubtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            cardSubtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -20),
            
            stackView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    private func applyThemeTokens() {
        view.backgroundColor = .themeBackground
        view.tintColor = .themeAccent
        titleLabel.textColor = .themePrimaryText
        descriptionLabel.textColor = .themeSecondaryText
        cardTitleLabel.textColor = .themePrimaryText
        cardSubtitleLabel.textColor = .themeSecondaryText

        themeOptionsControl.selectedSegmentTintColor = .themeAccent
        let normalAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.themeSecondaryText]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.themePrimaryText]
        themeOptionsControl.setTitleTextAttributes(normalAttributes, for: .normal)
        themeOptionsControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }

    private func bindObservers() {
        selectionObserver = NotificationCenter.default.addObserver(forName: ThemeManager.selectionDidChangeNotification,
                                                                    object: nil,
                                                                    queue: .main) { [weak self] notification in
            guard let rawValue = notification.userInfo?[ThemeManager.selectionUserInfoKey] as? Int,
                  let selection = ThemeSelection(rawValue: rawValue) else { return }
            self?.updateSelectionControl(with: selection)
        }
    }

    private func configureInitialState() {
        updateSelectionControl(with: ThemeManager.shared.selection)
    }

    private func updateSelectionControl(with selection: ThemeSelection) {
        themeOptionsControl.selectedSegmentIndex = selection.rawValue
    }

    @objc private func handleThemeSelection(_ sender: UISegmentedControl) {
        guard let selection = ThemeSelection(rawValue: sender.selectedSegmentIndex) else { return }
        ThemeManager.shared.selectTheme(selection)
    }

    private func updateCardShadow() {
        cardView.layer.shadowColor = UIColor.themeAccent.withAlphaComponent(0.08).cgColor
        cardView.layer.shadowRadius = 16
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
    }
}
