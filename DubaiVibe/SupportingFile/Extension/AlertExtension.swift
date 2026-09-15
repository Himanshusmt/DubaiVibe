import UIKit

extension UIAlertController {
    /// Keeps action titles on the brand gold instead of inheriting a
    /// first-responder caret color (gold) or the system link color (blue).
    func applyAppTint() {
        view.tintColor = AppPalette.gold
        stripDataDetectors(from: view)
    }

    private func stripDataDetectors(from view: UIView) {
        if let textView = view as? UITextView {
            textView.dataDetectorTypes = []
            textView.tintColor = AppPalette.gold
        }
        view.subviews.forEach { stripDataDetectors(from: $0) }
    }
}

extension UIViewController {
    func presentStyledAlert(_ alert: UIAlertController, animated: Bool = true, completion: (() -> Void)? = nil) {
        alert.applyAppTint()
        present(alert, animated: animated) {
            alert.applyAppTint()
            completion?()
        }
    }
}
