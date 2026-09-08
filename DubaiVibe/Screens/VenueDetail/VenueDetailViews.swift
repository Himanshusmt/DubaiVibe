import UIKit

/// Gold gradient CTA used by the deal card.
final class GoldGradientButton: UIButton {
    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        gradient.colors = [
            AppPalette.goldGradientTop.cgColor,
            AppPalette.goldGradientBottom.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        layer.insertSublayer(gradient, at: 0)
        layer.cornerRadius = 14
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }
}

/// Bottom-fading hero container so the overlay pills stay readable.
final class HeroImageView: UIImageView {
    private let fade = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        fade.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.30).cgColor,
            UIColor.black.withAlphaComponent(0.62).cgColor
        ]
        fade.locations = [0.35, 0.72, 1]
        layer.addSublayer(fade)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fade.frame = bounds
    }
}

/// Glyphs that don't ship with SF Symbols, drawn once and cached.
enum BrandGlyphs {
    static let instagram: UIImage = {
        let size = CGSize(width: 24, height: 24)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.9)

            let frame = CGRect(x: 2.5, y: 2.5, width: 19, height: 19)
            context.addPath(UIBezierPath(roundedRect: frame, cornerRadius: 6).cgPath)
            context.strokePath()

            context.addEllipse(in: CGRect(x: 8, y: 8, width: 8, height: 8))
            context.strokePath()

            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(x: 16.2, y: 6.1, width: 2.4, height: 2.4))
        }.withRenderingMode(.alwaysTemplate)
    }()

    static let shareNodes: UIImage = {
        let size = CGSize(width: 24, height: 24)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.7)

            let right = CGPoint(x: 17.5, y: 5.5)
            let left = CGPoint(x: 6.5, y: 12)
            let bottom = CGPoint(x: 17.5, y: 18.5)

            context.move(to: left)
            context.addLine(to: right)
            context.move(to: left)
            context.addLine(to: bottom)
            context.strokePath()

            for point in [right, left, bottom] {
                let dot = CGRect(x: point.x - 3.1, y: point.y - 3.1, width: 6.2, height: 6.2)
                context.addEllipse(in: dot)
            }
            context.strokePath()
        }.withRenderingMode(.alwaysTemplate)
    }()
}
