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

    /// Optional full-row tap target installed by the view controller for switch rows.
    private weak var rowTapButton: UIButton?

    override func awakeFromNib() {
        super.awakeFromNib()
        prepareInteractiveChrome()
    }

    override var isHighlighted: Bool {
        didSet {
            // Switch rows are driven by an overlay button — skip zoom/highlight.
            guard rowTapButton == nil, toggleSwitch == nil else { return }
            alpha = isHighlighted ? 0.72 : 1
            if isHighlighted {
                animatePressZoomIn()
            } else {
                animatePressZoomOut()
            }
        }
    }

    /// Install a full-row invisible button. Guarantees taps work even when a nested
    /// `UISwitch` / `UIScrollView` would otherwise cancel or steal touches.
    /// Dragging still scrolls because the scroll view can cancel this control's tracking.
    @discardableResult
    func installFullRowTapTarget(
        target: Any?,
        action: Selector
    ) -> UIButton {
        rowTapButton?.removeFromSuperview()

        let button = ScrollFriendlyButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.accessibilityLabel = titleLabel?.text
        addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        button.addTarget(target, action: action, for: .touchUpInside)
        bringSubviewToFront(button)
        rowTapButton = button

        // Switch becomes display-only; the overlay button owns the tap.
        toggleSwitch?.isUserInteractionEnabled = false
        isAccessibilityElement = false
        return button
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isUserInteractionEnabled, !isHidden, alpha > 0.01, bounds.contains(point) else {
            return nil
        }

        // Prefer the overlay button / any interactive control that actually wants the tap.
        for subview in subviews.reversed() {
            guard subview.isUserInteractionEnabled, !subview.isHidden, subview.alpha > 0.01 else { continue }
            let local = convert(point, to: subview)
            if let hit = subview.hitTest(local, with: event) {
                return hit
            }
        }

        // Decorative labels/icons are non-interactive — the row itself handles IB actions.
        return self
    }

    private func prepareInteractiveChrome() {
        // Labels / icons / stacks must not steal taps from the row.
        let decorative: [UIView?] = [
            iconImageView, titleLabel, subtitleLabel, valueLabel, chevronImageView, separatorView
        ]
        decorative.compactMap { $0 }.forEach { $0.isUserInteractionEnabled = false }

        for subview in subviews {
            if subview is UISwitch || subview is UIButton { continue }
            if subview is UIStackView {
                subview.isUserInteractionEnabled = false
                subview.subviews.forEach { $0.isUserInteractionEnabled = false }
            }
        }

        if toggleSwitch == nil {
            isAccessibilityElement = true
            accessibilityTraits.insert(.button)
        }
    }
}

/// UIButton that does not claim exclusive touch tracking, so UIScrollView can
/// cancel the touch and scroll when the user drags.
private final class ScrollFriendlyButton: UIButton {}

/// Lets dragging start on profile rows / buttons and still scroll the page.
final class ProfileScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl {
            return true
        }
        return super.touchesShouldCancel(in: view)
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

    func applyBrandTileChrome(corner: CGFloat = 14) {
        layer.cornerRadius = corner
        layer.cornerCurve = .continuous
        clipsToBounds = true
//        layer.borderWidth = 1
        layer.borderColor = AppPalette.gold.withAlphaComponent(0.65).cgColor
    }
}
