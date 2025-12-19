import UIKit
import ThemeKit

/// A reusable container view that automatically draws itself using theme dynamic colors.
public final class ThemeSurfaceView: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        layer.cornerRadius = 14
        if #available(iOS 13.0, *) {
            layer.cornerCurve = .continuous
        }
        backgroundColor = .themeSurface
        updateBorder()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else { return }
        updateBorder()
    }

    private func updateBorder() {
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.borderColor = UIColor.themeDivider.resolvedColor(with: traitCollection).cgColor
    }
}
