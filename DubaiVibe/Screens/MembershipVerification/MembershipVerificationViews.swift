import UIKit

/// Soft gold wash and diagonal wisps used behind the membership screen.
final class GoldAmbientGlowView: UIView {
    private let blob = CAGradientLayer()
    private let rayLayers: [CAGradientLayer] = (0..<4).map { _ in CAGradientLayer() }

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

        blob.type = .radial
        blob.colors = [
            AppPalette.gold.withAlphaComponent(0.42).cgColor,
            AppPalette.gold.withAlphaComponent(0.14).cgColor,
            UIColor.clear.cgColor
        ]
        blob.locations = [0, 0.34, 1]
        blob.startPoint = CGPoint(x: 0.5, y: 0.5)
        blob.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(blob)

        for (index, ray) in rayLayers.enumerated() {
            ray.type = .axial
            ray.colors = [
                UIColor.clear.cgColor,
                AppPalette.gold.withAlphaComponent(index.isMultiple(of: 2) ? 0.22 : 0.14).cgColor,
                UIColor.clear.cgColor
            ]
            ray.startPoint = CGPoint(x: 0, y: 0.5)
            ray.endPoint = CGPoint(x: 1, y: 0.5)
            layer.addSublayer(ray)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        blob.frame = bounds

        let angles: [CGFloat] = [-0.55, -0.18, 0.22, 0.58]
        for (index, ray) in rayLayers.enumerated() {
            let height = max(18, bounds.height * 0.08)
            ray.bounds = CGRect(x: 0, y: 0, width: bounds.width * 1.35, height: height)
            ray.position = CGPoint(x: bounds.midX, y: bounds.midY)
            ray.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            ray.transform = CATransform3DMakeRotation(angles[index], 0, 0, 1)
            ray.cornerRadius = height / 2
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
            AppPalette.gold.withAlphaComponent(0.55).cgColor,
            AppPalette.gold.withAlphaComponent(0.16).cgColor,
            UIColor.clear.cgColor
        ]
        glow.locations = [0, 0.4, 1]
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
