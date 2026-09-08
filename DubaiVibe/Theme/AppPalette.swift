import UIKit

/// The app ships dark-only, so these are literal values rather than adaptive colors.
enum AppPalette {
    static let gold = UIColor(hex: 0xE8B964)
    static let goldDim = UIColor(hex: 0xC9A05A)
    static let onGold = UIColor(hex: 0x121212)
    static let star = UIColor(hex: 0xF5B942)
    static let verified = UIColor(hex: 0x2F8BFF)

    static let background = UIColor(hex: 0x000000)
    static let surface = UIColor(hex: 0x141416)
    static let surfaceRaised = UIColor(hex: 0x1B1B1F)
    static let primaryText = UIColor(hex: 0xF5F5F7)
    static let secondaryText = UIColor(hex: 0x9A9AA2)
    static let separator = UIColor(hex: 0x2A2A2E)

    static let tagline = UIColor(hex: 0xC4C4CB)

    static let cardBorder = UIColor(hex: 0x26262A)
    static let chipFill = UIColor(hex: 0x141416)
    static let chipBorder = UIColor(hex: 0x2E2E34)
    static let searchFill = UIColor(hex: 0x121214)
    static let searchBorder = UIColor(hex: 0x2A2A2E)

    static let dealFill = UIColor(hex: 0x120F09)
    static let dealBorder = UIColor(hex: 0xE8B964, alpha: 0.40)
    static let crownFill = UIColor(hex: 0x0A0805)

    static let tabIdle = UIColor(hex: 0x8E8E96)
    static let badgeRed = UIColor(hex: 0xFF3B30)
    static let onlineGreen = UIColor(hex: 0x34C759)

    // Venue detail screen
    static let detailSubtitle = UIColor(hex: 0x86A2C6)
    static let detailCardFill = UIColor(hex: 0x0E0E10)
    static let detailCardBorder = UIColor(hex: 0x2E2E34)
    static let dealCardFill = UIColor(hex: 0x14110C)
    static let dealCardBorder = UIColor(hex: 0xE8B964, alpha: 0.55)
    static let goldGradientTop = UIColor(hex: 0xF2D089)
    static let goldGradientBottom = UIColor(hex: 0xD9A94E)
}

enum AppMetrics {
    /// Header controls sit on a wider gutter than the feed cards.
    static let screenGutter: CGFloat = 16
    static let cardGutter: CGFloat = 12
    static let cardRadius: CGFloat = 16
    static let chipHeight: CGFloat = 32
    static let searchHeight: CGFloat = 38
    static let heroHeight: CGFloat = 145
    static let dealHeight: CGFloat = 86
    static let brandTileWidth: CGFloat = 74
    static let brandTileHeight: CGFloat = 48
}

/// Screen geometry without touching the deprecated `UIScreen.main`.
enum ScreenMetrics {
    static func width(for view: UIView?) -> CGFloat {
        if let scene = view?.window?.windowScene {
            return scene.screen.bounds.width
        }
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first
        return scene?.screen.bounds.width ?? 393
    }
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
