import ObjectiveC
import UIKit

/// Soft press feedback shared by buttons and button-like controls.
extension UIView {
    func animatePressZoomIn(scale: CGFloat = 0.94) {
        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }

    func animatePressZoomOut() {
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.9,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            self.transform = .identity
        }
    }
}

/// Installs a zoom-in / zoom-out press animation on every `UIButton`
/// without changing call sites or storyboard wiring.
extension UIButton {
    private static var pressAnimationInstalledKey: UInt8 = 0
    private static var didEnableGlobalPressAnimation = false

    /// Call once at launch (e.g. from `AppDelegate`).
    static func enableGlobalPressAnimation() {
        guard !didEnableGlobalPressAnimation else { return }
        didEnableGlobalPressAnimation = true

        let originalSelector = #selector(UIView.didMoveToWindow)
        let swizzledSelector = #selector(UIButton.dv_pressAnimation_didMoveToWindow)

        guard
            let originalMethod = class_getInstanceMethod(UIButton.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIButton.self, swizzledSelector)
        else { return }

        // Safe when `didMoveToWindow` is inherited from `UIView`.
        if class_addMethod(
            UIButton.self,
            originalSelector,
            method_getImplementation(swizzledMethod),
            method_getTypeEncoding(swizzledMethod)
        ) {
            class_replaceMethod(
                UIButton.self,
                swizzledSelector,
                method_getImplementation(originalMethod),
                method_getTypeEncoding(originalMethod)
            )
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }

    /// Opt out for a specific button if needed.
    @IBInspectable var disablesPressAnimation: Bool {
        get { objc_getAssociatedObject(self, &Self.pressAnimationDisabledKey) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &Self.pressAnimationDisabledKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    private static var pressAnimationDisabledKey: UInt8 = 0

    @objc private func dv_pressAnimation_didMoveToWindow() {
        // After swizzle, this calls the original `didMoveToWindow`.
        dv_pressAnimation_didMoveToWindow()
        dv_installPressAnimationIfNeeded()
    }

    private func dv_installPressAnimationIfNeeded() {
        guard window != nil else { return }
        guard !disablesPressAnimation else { return }
        if objc_getAssociatedObject(self, &Self.pressAnimationInstalledKey) as? Bool == true {
            return
        }
        objc_setAssociatedObject(self, &Self.pressAnimationInstalledKey, true, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        addTarget(self, action: #selector(dv_handlePressIn), for: [.touchDown, .touchDragEnter])
        addTarget(
            self,
            action: #selector(dv_handlePressOut),
            for: [.touchUpInside, .touchUpOutside, .touchCancel, .touchDragExit]
        )
    }

    @objc private func dv_handlePressIn() {
        guard !disablesPressAnimation, isEnabled else { return }
        animatePressZoomIn()
    }

    @objc private func dv_handlePressOut() {
        guard !disablesPressAnimation else { return }
        animatePressZoomOut()
    }
}
