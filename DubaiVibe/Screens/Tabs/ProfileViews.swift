import UIKit

/// Storyboard card chrome only — put all row content in IB.
@IBDesignable
final class ProfileCardView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        applyChrome()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyChrome()
    }

    private func applyChrome() {
        backgroundColor = AppPalette.surface
        layer.cornerRadius = 18
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }
}

/// Thin control shell. Icons, titles, subtitles, chevrons, and switches live in the storyboard.
final class ProfileSettingRow: UIControl {
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var subtitleLabel: UILabel?
    @IBOutlet weak var valueLabel: UILabel?
    @IBOutlet weak var chevronImageView: UIImageView?
    @IBOutlet weak var toggleSwitch: UISwitch?
    @IBOutlet weak var separatorView: UIView?

    override var isHighlighted: Bool {
        didSet {
            guard toggleSwitch == nil || toggleSwitch?.isHidden == true else { return }
            alpha = isHighlighted ? 0.72 : 1
            if isHighlighted {
                animatePressZoomIn()
            } else {
                animatePressZoomOut()
            }
        }
    }
}

@IBDesignable
final class ProfileVIPBadgeView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        applyChrome()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        applyChrome()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }

    private func applyChrome() {
        backgroundColor = .clear
        layer.borderWidth = 1
        layer.borderColor = AppPalette.gold.withAlphaComponent(0.75).cgColor
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }
}

extension UIImageView {
    func applyProfileAvatarChrome(borderWidth: CGFloat = 3) {
        backgroundColor = AppPalette.surface
        tintColor = AppPalette.gold
        tintAdjustmentMode = .normal
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.borderWidth = borderWidth
        layer.borderColor = AppPalette.gold.cgColor
        layer.cornerCurve = .continuous
    }

    func makeCircular() {
        let side = min(bounds.width, bounds.height)
        guard side > 0 else { return }
        layer.cornerRadius = side / 2
    }
}

extension UIView {
    func applyCircularBadge(fill: UIColor = AppPalette.gold) {
        backgroundColor = fill
        clipsToBounds = true
        tintAdjustmentMode = .normal
        let side = min(bounds.width, bounds.height)
        if side > 0 {
            layer.cornerRadius = side / 2
        }
    }

    func applyBrandTileChrome(corner: CGFloat = 12) {
        layer.cornerRadius = corner
        layer.cornerCurve = .continuous
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = AppPalette.gold.withAlphaComponent(0.65).cgColor
    }
}
