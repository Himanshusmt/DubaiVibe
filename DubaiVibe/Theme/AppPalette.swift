import UIKit

/// The app ships dark-only, so these are literal values rather than adaptive colors.
enum AppPalette {
    static let gold = UIColor(hex: 0xE3B367)
    static let goldDim = UIColor(hex: 0xD8A04D)
    static let onGold = UIColor(hex: 0x000000)
    static let star = UIColor(hex: 0xF5B942)
    static let verified = UIColor(hex: 0x2F8BFF)

    static let background = UIColor(hex: 0x000000)
    static let surface = UIColor(hex: 0x181717)
    static let surfaceRaised = UIColor(hex: 0x1B1B1F)
    static let primaryText = UIColor(hex: 0xFFFFFF)
    static let secondaryText = UIColor(hex: 0xA3A3A3)
    static let separator = UIColor(hex: 0x2A2A2E)

    static let tagline = UIColor(hex: 0xA3A3A3)

    static let cardFill = UIColor(hex: 0x111112)
    static let cardBorder = UIColor(hex: 0x222225)
    static let chipFill = UIColor(hex: 0x171718)
    static let chipBorder = UIColor(hex: 0x2B2B2E)
    static let chipText = UIColor(hex: 0xE5E5E5)
    static let searchFill = UIColor(hex: 0x18181A)
    static let searchBorder = UIColor(hex: 0x262629)
    static let searchPlaceholder = UIColor(hex: 0x737373)
    static let locationFill = UIColor(hex: 0x181717)
    static let locationBorder = UIColor(hex: 0x2F2E2C)

    static let dealFill = UIColor(hex: 0x0B0B0C)
    /// Fallback / mid gold when a solid deal stroke is needed.
    static let dealBorder = UIColor(hex: 0xE2A645)
    /// Figma deal border (primary color): #FCE19B → #E2A645 → #B87B22
    static let dealBorderGradientTop = UIColor(hex: 0xFCE19B)
    static let dealBorderGradientMid = UIColor(hex: 0xE2A645)
    static let dealBorderGradientBottom = UIColor(hex: 0xB87B22)
    static let dealDetailText = UIColor(hex: 0xD4D4D4)
    static let exclusiveGold = UIColor(hex: 0xE3B367, alpha: 0.9)
    static let crownFill = UIColor(hex: 0x141310)

    static let tabIdle = UIColor(hex: 0x8E8E96)
    /// Figma QuickActionsFooter labels: #D4D4D4
    static let tabLabel = UIColor(hex: 0xD4D4D4)
    /// Chip fill: dark but a little see-through over the Explore feed.
    static let tabBarFill = UIColor(hex: 0x181717, alpha: 0.45)
    /// Figma pill stroke: #494949
    static let tabBarBorder = UIColor(hex: 0x494949)
    static let badgeRed = UIColor(hex: 0xFF453A)
    static let onlineGreen = UIColor(hex: 0x34C759)

    // Venue detail screen
    static let detailSubtitle = UIColor(hex: 0x86A2C6)
    static let detailCardFill = UIColor(hex: 0x0E0E10)
    static let detailCardBorder = UIColor(hex: 0x2E2E34)
    static let dealCardFill = UIColor(hex: 0x14110C)
    static let dealCardBorder = UIColor(hex: 0xE8B964, alpha: 0.55)
    /// Figma CTA / View Deal: #F3CE85 → #D8A04D
    static let goldGradientTop = UIColor(hex: 0xF3CE85)
    static let goldGradientBottom = UIColor(hex: 0xD8A04D)
    /// Unlock Deal: linear-gradient(97.73deg, #FAD77A 0%, #E3A338 50%, #B87B14 100%)
    static let unlockDealGradientStart = UIColor(hex: 0xFAD77A)
    static let unlockDealGradientMid = UIColor(hex: 0xE3A338)
    static let unlockDealGradientEnd = UIColor(hex: 0xB87B14)
    /// Exclusive deal panel fill: yellow wash (#FFA903 @ 17%) for top 17%, black (#0B0B0C) for remaining 83%.
    static let dealGradientWash = UIColor(hex: 0xFFA903, alpha: 0.17)
}

enum AppMetrics {
    /// Header controls sit on a wider gutter than the feed cards.
    static let screenGutter: CGFloat = 16
    static let cardGutter: CGFloat = 16
    static let cardRadius: CGFloat = 24
    static let chipHeight: CGFloat = 32
    static let chipGap: CGFloat = 8
    static let searchHeight: CGFloat = 38
    static let heroHeight: CGFloat = 176
    static let dealHeight: CGFloat = 78
    static let brandTileWidth: CGFloat = 74
    static let brandTileHeight: CGFloat = 48

    /// Compact centered Home / Profile chip (230×80 capsule).
    static let floatingTabPillSize = CGSize(width: 230, height: 80)
    /// Gap between the chip and the home-indicator safe area.
    static let floatingTabSafeGap: CGFloat = 2
    static let floatingTabItemWidth: CGFloat = 100
    static let floatingTabItemSpacing: CGFloat = 8
    static let floatingTabCornerRadius: CGFloat = 40
    /// Icon inset from the top of the chip; title inset from the bottom.
    static let floatingTabContentInset: CGFloat = 15
    /// Pull icon and title toward each other by this many points.
    static let floatingTabIconTitleTighten: CGFloat = 2
    static let floatingTabIconSize: CGFloat = 24
    static let floatingTabTitleFontSize: CGFloat = 11

    static func homeIndicatorInset(for view: UIView) -> CGFloat {
        view.window?.safeAreaInsets.bottom ?? 34
    }

    static func floatingTabBottomInset(for view: UIView) -> CGFloat {
        homeIndicatorInset(for: view) + floatingTabSafeGap
    }

    /// Centered 230×80 chip sitting just above the home-indicator safe area.
    static func floatingTabChipFrame(in host: UIView) -> CGRect {
        let pill = floatingTabPillSize
        let safeBottom = host.window?.safeAreaInsets.bottom ?? homeIndicatorInset(for: host)
        return CGRect(
            x: (host.bounds.width - pill.width) / 2,
            y: host.bounds.height - safeBottom - floatingTabSafeGap - pill.height,
            width: pill.width,
            height: pill.height
        )
    }
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
