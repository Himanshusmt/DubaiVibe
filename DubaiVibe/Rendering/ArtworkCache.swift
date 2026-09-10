import UIKit

/// In-memory artwork cache. Images are rendered once and reused across cell recycle.
enum ArtworkCache {
    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 64
        cache.totalCostLimit = 32 * 1024 * 1024
        return cache
    }()

    static func image(for venue: Venue, size: CGSize) -> UIImage {
        let key = "\(venue.id.uuidString)-\(Int(size.width))x\(Int(size.height))" as NSString
        if let cached = cache.object(forKey: key) {
            return cached
        }
        let image: UIImage
        if let photo = venue.photoImage, size.width > 0, size.height > 0 {
            image = ArtworkRenderer.renderPhoto(photo, size: size)
        } else {
            image = ArtworkRenderer.render(venue: venue, size: size)
        }
        cache.setObject(image, forKey: key, cost: Int(size.width * size.height * 4))
        return image
    }

    static func prefetch(_ venues: [Venue], size: CGSize) {
        for venue in venues {
            _ = image(for: venue, size: size)
        }
    }
}

enum ArtworkRenderer {
    static func renderPhoto(_ photo: UIImage, size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = true
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            let scale = max(size.width / photo.size.width, size.height / photo.size.height)
            let drawSize = CGSize(width: photo.size.width * scale, height: photo.size.height * scale)
            let origin = CGPoint(
                x: (size.width - drawSize.width) / 2,
                y: (size.height - drawSize.height) / 2
            )
            photo.draw(in: CGRect(origin: origin, size: drawSize))
        }
    }

    static func render(venue: Venue, size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat.preferred()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: size)
            paintBackground(style: venue.artworkStyle, in: rect, context: ctx.cgContext)
            paintAtmosphere(style: venue.artworkStyle, in: rect, context: ctx.cgContext)
        }
    }

    private static func paintBackground(style: ArtworkStyle, in rect: CGRect, context: CGContext) {
        let colors: [CGColor]
        switch style {
        case .zuma:
            colors = [UIColor(hex: 0x1C120C).cgColor, UIColor(hex: 0x6B2A16).cgColor, UIColor(hex: 0xC45A2A).cgColor]
        case .rooftop:
            colors = [UIColor(hex: 0x140B2E).cgColor, UIColor(hex: 0x3B1D6E).cgColor, UIColor(hex: 0xE07A4A).cgColor]
        case .izakaya:
            colors = [UIColor(hex: 0x12100E).cgColor, UIColor(hex: 0x3A2A1C).cgColor, UIColor(hex: 0xB08A4A).cgColor]
        case .lounge:
            colors = [UIColor(hex: 0x0E1418).cgColor, UIColor(hex: 0x1C3A44).cgColor, UIColor(hex: 0xC9A36A).cgColor]
        case .cafe:
            colors = [UIColor(hex: 0x2A1C14).cgColor, UIColor(hex: 0x7A4A28).cgColor, UIColor(hex: 0xE8C9A0).cgColor]
        case .club:
            colors = [UIColor(hex: 0x0A0A0C).cgColor, UIColor(hex: 0x1A1030).cgColor, UIColor(hex: 0x6A3CFF).cgColor]
        case .beach:
            colors = [UIColor(hex: 0x0B2A3A).cgColor, UIColor(hex: 0x1D6E86).cgColor, UIColor(hex: 0xF0C98A).cgColor]
        case .brunch:
            colors = [UIColor(hex: 0x2E1A20).cgColor, UIColor(hex: 0x8A4450).cgColor, UIColor(hex: 0xF2CBB4).cgColor]
        case .wellness:
            colors = [UIColor(hex: 0x101418).cgColor, UIColor(hex: 0x24333C).cgColor, UIColor(hex: 0x7FA6B8).cgColor]
        case .court:
            colors = [UIColor(hex: 0x0C1F14).cgColor, UIColor(hex: 0x1E4A2C).cgColor, UIColor(hex: 0xB6D96A).cgColor]
        case .salon:
            colors = [UIColor(hex: 0x241825).cgColor, UIColor(hex: 0x5E3352).cgColor, UIColor(hex: 0xE8B8C8).cgColor]
        }

        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: [0, 0.45, 1]
        )!
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: rect.midX, y: 0),
            end: CGPoint(x: rect.midX, y: rect.maxY),
            options: []
        )
    }

    private static func paintAtmosphere(style: ArtworkStyle, in rect: CGRect, context: CGContext) {
        context.setBlendMode(.plusLighter)
        context.setFillColor(UIColor.white.withAlphaComponent(0.08).cgColor)
        let glow = CGRect(
            x: rect.width * 0.15,
            y: rect.height * 0.08,
            width: rect.width * 0.7,
            height: rect.height * 0.35
        )
        context.fillEllipse(in: glow)

        context.setBlendMode(.normal)
        context.setFillColor(UIColor.black.withAlphaComponent(0.22).cgColor)
        context.fill(CGRect(x: 0, y: rect.height * 0.62, width: rect.width, height: rect.height * 0.38))

        switch style {
        case .rooftop, .club:
            drawSkyline(in: rect, context: context)
        case .zuma, .izakaya:
            drawLanterns(in: rect, context: context)
        case .lounge, .beach, .wellness:
            drawHorizon(in: rect, context: context)
        case .cafe, .brunch, .salon:
            drawWarmWash(in: rect, context: context)
        case .court:
            drawCourtLines(in: rect, context: context)
        }
    }

    private static func drawCourtLines(in rect: CGRect, context: CGContext) {
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.22).cgColor)
        context.setLineWidth(1.5)
        let inset = rect.insetBy(dx: rect.width * 0.14, dy: rect.height * 0.24)
        context.stroke(inset)
        context.move(to: CGPoint(x: inset.midX, y: inset.minY))
        context.addLine(to: CGPoint(x: inset.midX, y: inset.maxY))
        context.strokePath()
    }

    private static func drawSkyline(in rect: CGRect, context: CGContext) {
        context.setFillColor(UIColor.black.withAlphaComponent(0.35).cgColor)
        var generator = SeededGenerator(seed: 0xC0FFEE)
        var x: CGFloat = 12
        while x < rect.width {
            let width = CGFloat.random(in: 18...42, using: &generator)
            let height = CGFloat.random(in: rect.height * 0.18...rect.height * 0.42, using: &generator)
            context.fill(CGRect(x: x, y: rect.height - height - 8, width: width, height: height))
            x += width + 6
        }
    }

    private static func drawLanterns(in rect: CGRect, context: CGContext) {
        context.setFillColor(UIColor(hex: 0xE8B964).withAlphaComponent(0.35).cgColor)
        for offset in [0.18, 0.38, 0.62, 0.82] {
            let lamp = CGRect(x: rect.width * offset, y: rect.height * 0.22, width: 10, height: 16)
            context.fillEllipse(in: lamp)
        }
    }

    private static func drawHorizon(in rect: CGRect, context: CGContext) {
        context.setStrokeColor(UIColor.white.withAlphaComponent(0.2).cgColor)
        context.setLineWidth(1.2)
        context.move(to: CGPoint(x: 0, y: rect.height * 0.58))
        context.addLine(to: CGPoint(x: rect.width, y: rect.height * 0.52))
        context.strokePath()
    }

    private static func drawWarmWash(in rect: CGRect, context: CGContext) {
        context.setFillColor(UIColor(hex: 0xF5D7A8).withAlphaComponent(0.16).cgColor)
        context.fillEllipse(in: CGRect(x: rect.width * 0.45, y: -rect.height * 0.1, width: rect.width * 0.7, height: rect.height * 0.55))
    }

}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
