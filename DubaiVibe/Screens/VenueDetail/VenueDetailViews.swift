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
        // Keep IB title/image above the gradient layer.
        if let titleLabel { bringSubviewToFront(titleLabel) }
        if let imageView { bringSubviewToFront(imageView) }
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
        // UIImageView opts out of touch delivery, but the hero hosts overlay controls.
        isUserInteractionEnabled = true
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

    /// Deal-banner crown: a pointed centre shield flanked by two thin arms over a base band.
    static let crown: UIImage = {
        let size = CGSize(width: 28, height: 28)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext

            let shield = UIBezierPath()
            shield.move(to: CGPoint(x: 14, y: 0.6))
            shield.addCurve(
                to: CGPoint(x: 20.2, y: 9.0),
                controlPoint1: CGPoint(x: 15.6, y: 3.4),
                controlPoint2: CGPoint(x: 18.0, y: 6.4)
            )
            shield.addLine(to: CGPoint(x: 19.6, y: 20.8))
            shield.addLine(to: CGPoint(x: 8.4, y: 20.8))
            shield.addLine(to: CGPoint(x: 7.8, y: 9.0))
            shield.addCurve(
                to: CGPoint(x: 14, y: 0.6),
                controlPoint1: CGPoint(x: 10.0, y: 6.4),
                controlPoint2: CGPoint(x: 12.4, y: 3.4)
            )
            shield.fill()

            context.setLineWidth(2.3)
            context.setLineCap(.round)
            for direction in [CGFloat(-1), 1] {
                context.move(to: CGPoint(x: 14 + direction * 10.6, y: 8.2))
                context.addLine(to: CGPoint(x: 14 + direction * 7.0, y: 20.8))
            }
            context.strokePath()

            UIBezierPath(
                roundedRect: CGRect(x: 4.8, y: 22.6, width: 18.4, height: 3.0),
                cornerRadius: 0.8
            ).fill()

            context.setBlendMode(.clear)
            let notch = UIBezierPath()
            notch.move(to: CGPoint(x: 12.2, y: 22.4))
            notch.addLine(to: CGPoint(x: 15.8, y: 22.4))
            notch.addLine(to: CGPoint(x: 14, y: 24.4))
            notch.close()
            notch.fill()
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Solid teardrop map marker used by the city picker.
    static let mapPin: UIImage = {
        let size = CGSize(width: 20, height: 24)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let pin = UIBezierPath()
            pin.move(to: CGPoint(x: 10, y: 23))
            pin.addCurve(
                to: CGPoint(x: 1, y: 9.4),
                controlPoint1: CGPoint(x: 5.4, y: 16.6),
                controlPoint2: CGPoint(x: 1, y: 12.6)
            )
            pin.addArc(
                withCenter: CGPoint(x: 10, y: 9.4),
                radius: 9,
                startAngle: .pi,
                endAngle: 0,
                clockwise: true
            )
            pin.addCurve(
                to: CGPoint(x: 10, y: 23),
                controlPoint1: CGPoint(x: 19, y: 12.6),
                controlPoint2: CGPoint(x: 14.6, y: 16.6)
            )
            pin.fill()

            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.fillEllipse(in: CGRect(x: 6.6, y: 6, width: 6.8, height: 6.8))
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Martini glass for the bars chip.
    static let martini: UIImage = {
        let size = CGSize(width: 22, height: 22)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.6)
            context.setLineJoin(.round)
            context.setLineCap(.round)

            context.move(to: CGPoint(x: 2.4, y: 3.4))
            context.addLine(to: CGPoint(x: 19.6, y: 3.4))
            context.addLine(to: CGPoint(x: 11, y: 12.4))
            context.closePath()
            context.strokePath()

            context.move(to: CGPoint(x: 11, y: 12.4))
            context.addLine(to: CGPoint(x: 11, y: 18.4))
            context.move(to: CGPoint(x: 5.6, y: 18.8))
            context.addLine(to: CGPoint(x: 16.4, y: 18.8))
            context.strokePath()
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Mirror ball for the nightlife chip.
    static let discoBall: UIImage = {
        let size = CGSize(width: 22, height: 22)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            let ball = CGRect(x: 3, y: 5, width: 16, height: 16)

            context.move(to: CGPoint(x: 11, y: 1.4))
            context.addLine(to: CGPoint(x: 11, y: 5))
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.4)
            context.strokePath()

            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: ball)

            // Punch the lattice out of the sphere so the fill reads as facets.
            context.setBlendMode(.clear)
            context.setLineWidth(1)
            context.saveGState()
            context.addEllipse(in: ball)
            context.clip()
            for row in stride(from: ball.minY + 3.2, to: ball.maxY, by: 3.2) {
                context.move(to: CGPoint(x: ball.minX, y: row))
                context.addLine(to: CGPoint(x: ball.maxX, y: row))
            }
            context.strokePath()
            for inset in stride(from: CGFloat(0), through: 6, by: 3) {
                let oval = ball.insetBy(dx: inset, dy: 0)
                context.addEllipse(in: oval)
            }
            context.strokePath()
            context.restoreGState()
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Steaming mug for the cafés chip.
    static let mug: UIImage = {
        let size = CGSize(width: 22, height: 22)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.3)
            context.setLineCap(.round)

            context.move(to: CGPoint(x: 8.2, y: 5.4))
            context.addCurve(
                to: CGPoint(x: 8.2, y: 1.8),
                control1: CGPoint(x: 6.4, y: 3.8),
                control2: CGPoint(x: 10, y: 3.4)
            )
            context.move(to: CGPoint(x: 12.2, y: 5.4))
            context.addCurve(
                to: CGPoint(x: 12.2, y: 1.8),
                control1: CGPoint(x: 10.4, y: 3.8),
                control2: CGPoint(x: 14, y: 3.4)
            )
            context.strokePath()

            let cup = UIBezierPath(
                roundedRect: CGRect(x: 2.4, y: 8, width: 12.4, height: 10.6),
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 3.4, height: 3.4)
            )
            cup.fill()

            context.setLineWidth(1.7)
            context.addArc(
                center: CGPoint(x: 15.2, y: 11.8),
                radius: 3.4,
                startAngle: -.pi / 2,
                endAngle: .pi / 2,
                clockwise: false
            )
            context.strokePath()
        }.withRenderingMode(.alwaysTemplate)
    }()
}
