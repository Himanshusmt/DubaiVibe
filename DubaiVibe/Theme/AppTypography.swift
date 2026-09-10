import UIKit

/// Inter typeface from the Explore Figma file, with SF Pro fallback.
enum AppTypography {
    enum Weight {
        case regular
        case medium
        case semibold
        case bold

        var fontName: String {
            switch self {
            case .regular: return "Inter-Regular"
            case .medium: return "Inter-Medium"
            case .semibold: return "Inter-SemiBold"
            case .bold: return "Inter-Bold"
            }
        }

        var systemWeight: UIFont.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }

    static func font(_ weight: Weight, size: CGFloat) -> UIFont {
        UIFont(name: weight.fontName, size: size)
            ?? .systemFont(ofSize: size, weight: weight.systemWeight)
    }
}
