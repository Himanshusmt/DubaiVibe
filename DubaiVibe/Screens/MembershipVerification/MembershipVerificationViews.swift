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
        glow.type = .radial
        glow.colors = [
            AppPalette.gold.withAlphaComponent(0.34).cgColor,
            AppPalette.gold.withAlphaComponent(0.26).cgColor,
            UIColor.clear.cgColor
        ]
        glow.locations = [0, 0.55, 1]
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

/// Keeps a square (or circle) clipped to its bounds so storyboard corner radii stay round on any size.
final class CircularImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let side = min(bounds.width, bounds.height)
        layer.cornerRadius = side / 2
        layer.cornerCurve = .circular
        clipsToBounds = true
        // Border is centered on the edge; without this, half the stroke can look clipped.
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
