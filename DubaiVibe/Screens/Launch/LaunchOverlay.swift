import UIKit

/// Keeps a copy of the launch storyboard on top of the window so the branding stays
/// visible for a minimum duration, even when the app finishes launching sooner.
enum LaunchOverlay {
    static let minimumDisplayDuration: TimeInterval = 0.3
    private static let fadeDuration: TimeInterval = 0.2

    private static var launchTimestamp = CFAbsoluteTimeGetCurrent()
    private static var overlayController: UIViewController?
    private static var hasRun = false

    /// Call as early as possible so the visible duration is measured from app start.
    static func begin() {
        launchTimestamp = CFAbsoluteTimeGetCurrent()
    }

    static func install(in window: UIWindow) {
        guard !hasRun else { return }
        hasRun = true

        guard let controller = UIStoryboard(name: "LaunchScreen", bundle: .main).instantiateInitialViewController() else {
            return
        }

        let overlay = controller.view!
        overlay.frame = window.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        window.addSubview(overlay)
        overlayController = controller

        let elapsed = CFAbsoluteTimeGetCurrent() - launchTimestamp
        let remaining = max(0, minimumDisplayDuration - elapsed)
        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
            dismiss()
        }
    }

    private static func dismiss() {
        guard let overlay = overlayController?.view else { return }
        UIView.animate(withDuration: fadeDuration) {
            overlay.alpha = 0
        } completion: { _ in
            overlay.removeFromSuperview()
            overlayController = nil
        }
    }
}
