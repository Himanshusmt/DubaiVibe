import UIKit

/// Faint gold wash behind the membership screen: a broad bloom across the middle
/// and a warmer one rising from the bottom edge. Pin this to the full screen.
///
/// Radii and opacities are sampled from the reference design, where the background
/// stays near-black (peak gold opacity is 17% at the bottom edge).
final class GoldAmbientGlowView: UIView {
    private struct Bloom {
        /// Center and radii as fractions of the view's bounds.
        let center: CGPoint
        let radius: CGSize
        let innerOpacity: CGFloat
        let midOpacity: CGFloat
    }

    private static let blooms = [
        Bloom(
            center: CGPoint(x: 0.5, y: 0.475),
            radius: CGSize(width: 1.385, height: 0.43),
            innerOpacity: 0.094,
            midOpacity: 0.039
        ),
        Bloom(
            center: CGPoint(x: 0.5, y: 0.977),
            radius: CGSize(width: 0.77, height: 0.192),
            innerOpacity: 0.17,
            midOpacity: 0.07
        )
    ]

    private let gradients = GoldAmbientGlowView.blooms.map { _ in CAGradientLayer() }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        clipsToBounds = false

        for (bloom, gradient) in zip(Self.blooms, gradients) {
            gradient.type = .radial
            gradient.colors = [
                AppPalette.gold.withAlphaComponent(bloom.innerOpacity).cgColor,
                AppPalette.gold.withAlphaComponent(bloom.midOpacity).cgColor,
                UIColor.clear.cgColor
            ]
            gradient.locations = [0, 0.45, 1]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradient.endPoint = CGPoint(x: 1, y: 1)
            layer.addSublayer(gradient)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        for (bloom, gradient) in zip(Self.blooms, gradients) {
            let radius = CGSize(
                width: bounds.width * bloom.radius.width,
                height: bounds.height * bloom.radius.height
            )
            gradient.frame = CGRect(
                x: bounds.width * bloom.center.x - radius.width,
                y: bounds.height * bloom.center.y - radius.height,
                width: radius.width * 2,
                height: radius.height * 2
            )
        }
    }
}

/// Tight gold bloom behind the shield on the code card.
final class GoldHaloView: UIView {
    private let glow = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        clipsToBounds = false
        glow.type = .radial
        glow.colors = [
            AppPalette.gold.withAlphaComponent(0.42).cgColor,
            AppPalette.gold.withAlphaComponent(0.22).cgColor,
            AppPalette.gold.withAlphaComponent(0.06).cgColor,
            UIColor.clear.cgColor
        ]
        glow.locations = [0, 0.35, 0.65, 1]
        glow.startPoint = CGPoint(x: 0.5, y: 0.5)
        glow.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(glow)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        glow.frame = bounds
    }
}

/// Metallic gold disc used for the benefit checkmarks.
final class GoldGradientCircleView: CircleView {
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    private func setupGradient() {
        gradient.colors = [
            AppPalette.goldGradientTop.cgColor,
            AppPalette.goldGradientBottom.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = min(bounds.width, bounds.height) / 2
    }
}

/// Clips its image to a true circle after every layout pass.
final class CircularImageView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.masksToBounds = true
        layer.cornerCurve = .circular
        layer.maskedCorners = [
            .layerMinXMinYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMaxXMaxYCorner
        ]
        setContentHuggingPriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyCircleClip()
    }

    override var bounds: CGRect {
        didSet {
            guard bounds != oldValue else { return }
            applyCircleClip()
        }
    }

    private func applyCircleClip() {
        let side = min(bounds.width, bounds.height)
        guard side > 0 else { return }
        layer.cornerRadius = side / 2
        layer.cornerCurve = .circular
        clipsToBounds = true
        layer.masksToBounds = true
    }
}

class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        clipsToBounds = true
    }
}
