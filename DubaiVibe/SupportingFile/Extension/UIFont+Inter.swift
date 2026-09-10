import UIKit
import ObjectiveC

enum AppFont {
    static func regular(_ size: CGFloat) -> UIFont {
        UIFont.inter(size: size, weight: .regular)
    }

    static func medium(_ size: CGFloat) -> UIFont {
        UIFont.inter(size: size, weight: .medium)
    }

    static func semibold(_ size: CGFloat) -> UIFont {
        UIFont.inter(size: size, weight: .semibold)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        UIFont.inter(size: size, weight: .bold)
    }
}

extension UIFont {
    /// Maps app weights to bundled Inter faces. Does not call `systemFont` (safe after swizzle).
    static func inter(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let name = interPostScriptName(for: weight)
        if let font = UIFont(name: name, size: size) {
            return font
        }
        // Prefer original system font after swizzle; Helvetica avoids recursion if fonts failed to load.
        return UIFont.inter_swizzled_systemFont(ofSize: size, weight: weight)
    }

    static func installInterAsSystemFont() {
        InterFontSwizzle.installOnce()
    }

    private static func interPostScriptName(for weight: UIFont.Weight) -> String {
        if weight < .medium { return "Inter-Regular" }
        if weight < .semibold { return "Inter-Medium" }
        if weight < .bold { return "Inter-SemiBold" }
        return "Inter-Bold"
    }

    @objc fileprivate class func inter_swizzled_systemFont(ofSize size: CGFloat) -> UIFont {
        if let font = UIFont(name: "Inter-Regular", size: size) {
            return font
        }
        // After exchange this is UIKit's original `systemFont(ofSize:)`.
        return UIFont.inter_swizzled_systemFont(ofSize: size)
    }

    @objc fileprivate class func inter_swizzled_systemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        if let font = UIFont(name: interPostScriptName(for: weight), size: size) {
            return font
        }
        // After exchange this is UIKit's original `systemFont(ofSize:weight:)`.
        return UIFont.inter_swizzled_systemFont(ofSize: size, weight: weight)
    }

    @objc fileprivate class func inter_swizzled_boldSystemFont(ofSize size: CGFloat) -> UIFont {
        if let font = UIFont(name: "Inter-Bold", size: size) {
            return font
        }
        return UIFont.inter_swizzled_boldSystemFont(ofSize: size)
    }
}

private enum InterFontSwizzle {
    private static let lock = NSLock()
    private static var didInstall = false

    static func installOnce() {
        lock.lock()
        defer { lock.unlock() }
        guard !didInstall else { return }
        didInstall = true

        swizzleClassMethod(
            of: UIFont.self,
            original: #selector(UIFont.systemFont(ofSize:)),
            swizzled: #selector(UIFont.inter_swizzled_systemFont(ofSize:))
        )
        swizzleClassMethod(
            of: UIFont.self,
            original: #selector(UIFont.systemFont(ofSize:weight:)),
            swizzled: #selector(UIFont.inter_swizzled_systemFont(ofSize:weight:))
        )
        swizzleClassMethod(
            of: UIFont.self,
            original: #selector(UIFont.boldSystemFont(ofSize:)),
            swizzled: #selector(UIFont.inter_swizzled_boldSystemFont(ofSize:))
        )
    }

    private static func swizzleClassMethod(of cls: AnyClass, original: Selector, swizzled: Selector) {
        guard
            let originalMethod = class_getClassMethod(cls, original),
            let swizzledMethod = class_getClassMethod(cls, swizzled)
        else {
            assertionFailure("Inter font swizzle failed for \(NSStringFromSelector(original))")
            return
        }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
