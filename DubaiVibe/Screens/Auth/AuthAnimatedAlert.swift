import UIKit

enum AuthAlertStyle {
    case info
    case warning
    case success

    var iconName: String {
        switch self {
        case .info: return "info"
        case .warning: return "exclamationmark"
        case .success: return "checkmark"
        }
    }

    static func inferred(fromTitle title: String, message: String) -> AuthAlertStyle {
        let blob = "\(title) \(message)".lowercased()
        if blob.contains("saved")
            || blob.contains("success")
            || blob.contains("updated")
            || blob.contains("copied") {
            return .success
        }
        if title.lowercased() == "error"
            || blob.contains("please enter")
            || blob.contains("invalid")
            || blob.contains("must be")
            || blob.contains("expired")
            || blob.contains("failed")
            || blob.contains("needed")
            || blob.contains("unable") {
            return .warning
        }
        return .info
    }
}

extension UIView {
    func shakeForValidation() {
        if layer.borderWidth > 0 {
            layer.borderColor = AppPalette.gold.cgColor
        }
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shake.duration = 0.42
        shake.values = [0, -8, 8, -6, 6, -3, 3, 0]
        layer.add(shake, forKey: "validationShake")
    }
}

extension UIViewController {
    func showAnimatedAlert(
        title: String,
        message: String,
        style: AuthAlertStyle = .info,
        actionTitle: String = "OK",
        onAction: (() -> Void)? = nil
    ) {
        view.endEditing(true)
        AuthAnimatedAlertView.show(
            on: view.window ?? view,
            title: title,
            message: message,
            style: style,
            actionTitle: actionTitle,
            onAction: onAction
        )
    }

    func showValidationAlert(_ message: String, highlighting views: UIView?...) {
        views.compactMap { $0 }.forEach { $0.shakeForValidation() }
        showAnimatedAlert(title: "Check your details", message: message, style: .warning)
    }

    func showNameValidationAlert(_ message: String, firstNameField: UIView?, lastNameField: UIView?) {
        let highlight: UIView?
        if message.localizedCaseInsensitiveContains("first") {
            highlight = firstNameField
        } else if message.localizedCaseInsensitiveContains("last") {
            highlight = lastNameField
        } else {
            highlight = firstNameField
        }
        showValidationAlert(message, highlighting: highlight)
    }
}

final class AuthAnimatedAlertView: UIView {
    private static let overlayTag = 8_818_181

    private let style: AuthAlertStyle
    private let onAction: (() -> Void)?

    private let dimView = UIView()
    private let card = UIView()
    private let iconHalo = UIView()
    private let iconBadge = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let actionButton = GoldGradientButton(type: .system)
    private let pulseRing = CAShapeLayer()

    static func show(
        on host: UIView,
        title: String,
        message: String,
        style: AuthAlertStyle,
        actionTitle: String,
        onAction: (() -> Void)?
    ) {
        host.viewWithTag(overlayTag)?.removeFromSuperview()

        let alert = AuthAnimatedAlertView(
            title: title,
            message: message,
            style: style,
            actionTitle: actionTitle,
            onAction: onAction
        )
        alert.tag = overlayTag
        host.addSubview(alert)
        NSLayoutConstraint.activate([
            alert.topAnchor.constraint(equalTo: host.topAnchor),
            alert.leadingAnchor.constraint(equalTo: host.leadingAnchor),
            alert.trailingAnchor.constraint(equalTo: host.trailingAnchor),
            alert.bottomAnchor.constraint(equalTo: host.bottomAnchor)
        ])
        host.layoutIfNeeded()
        alert.animateIn()
    }

    private init(
        title: String,
        message: String,
        style: AuthAlertStyle,
        actionTitle: String,
        onAction: (() -> Void)?
    ) {
        self.style = style
        self.onAction = onAction
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        accessibilityViewIsModal = true
        build(title: title, message: message, actionTitle: actionTitle)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let inset: CGFloat = 4
        pulseRing.path = UIBezierPath(
            ovalIn: iconHalo.bounds.insetBy(dx: inset, dy: inset)
        ).cgPath
        pulseRing.frame = iconHalo.bounds
    }

    private func build(title: String, message: String, actionTitle: String) {
        dimView.translatesAutoresizingMaskIntoConstraints = false
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.62)
        dimView.alpha = 0
        let dimTap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(dimTap)

        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = AppPalette.surfaceRaised
        card.layer.cornerRadius = 22
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = AppPalette.gold.withAlphaComponent(0.38).cgColor
        card.layer.shadowColor = AppPalette.gold.cgColor
        card.layer.shadowOpacity = 0.18
        card.layer.shadowRadius = 22
        card.layer.shadowOffset = CGSize(width: 0, height: 10)
        card.alpha = 0

        iconHalo.translatesAutoresizingMaskIntoConstraints = false
        iconHalo.backgroundColor = .clear
        iconHalo.isUserInteractionEnabled = false

        pulseRing.fillColor = UIColor.clear.cgColor
        pulseRing.strokeColor = AppPalette.gold.withAlphaComponent(0.55).cgColor
        pulseRing.lineWidth = 1.5
        iconHalo.layer.addSublayer(pulseRing)

        iconBadge.translatesAutoresizingMaskIntoConstraints = false
        iconBadge.backgroundColor = AppPalette.gold.withAlphaComponent(0.14)
        iconBadge.layer.cornerRadius = 28
        iconBadge.layer.cornerCurve = .continuous
        iconBadge.layer.borderWidth = 1
        iconBadge.layer.borderColor = AppPalette.gold.withAlphaComponent(0.55).cgColor

        let symbol = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: style.iconName, withConfiguration: symbol)
        iconView.tintColor = AppPalette.gold
        iconView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.font = AppTypography.font(.bold, size: 20)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.textColor = AppPalette.secondaryText
        messageLabel.font = AppTypography.font(.regular, size: 15)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setTitle(actionTitle, for: .normal)
        actionButton.setTitleColor(AppPalette.onGold, for: .normal)
        actionButton.titleLabel?.font = AppTypography.font(.semibold, size: 16)
        actionButton.layer.cornerRadius = 14
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        addSubview(dimView)
        addSubview(card)
        card.addSubview(iconHalo)
        iconHalo.addSubview(iconBadge)
        iconBadge.addSubview(iconView)
        card.addSubview(titleLabel)
        card.addSubview(messageLabel)
        card.addSubview(actionButton)

        let cardWidth = card.widthAnchor.constraint(equalToConstant: 300)
        cardWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: topAnchor),
            dimView.leadingAnchor.constraint(equalTo: leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: bottomAnchor),

            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -12),
            card.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 36),
            card.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -36),
            cardWidth,

            iconHalo.topAnchor.constraint(equalTo: card.topAnchor, constant: 26),
            iconHalo.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iconHalo.widthAnchor.constraint(equalToConstant: 72),
            iconHalo.heightAnchor.constraint(equalToConstant: 72),

            iconBadge.centerXAnchor.constraint(equalTo: iconHalo.centerXAnchor),
            iconBadge.centerYAnchor.constraint(equalTo: iconHalo.centerYAnchor),
            iconBadge.widthAnchor.constraint(equalToConstant: 56),
            iconBadge.heightAnchor.constraint(equalToConstant: 56),

            iconView.centerXAnchor.constraint(equalTo: iconBadge.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBadge.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: iconHalo.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            messageLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),

            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 22),
            actionButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func animateIn() {
        TapticEngine.impact.prepare(.medium)
        TapticEngine.notification.prepare()
        card.transform = CGAffineTransform(translationX: 0, y: 28).scaledBy(x: 0.84, y: 0.84)
        iconBadge.transform = CGAffineTransform(scaleX: 0.35, y: 0.35)

        UIView.animate(withDuration: 0.28) {
            self.dimView.alpha = 1
        }

        UIView.animate(
            withDuration: 0.54,
            delay: 0.02,
            usingSpringWithDamping: 0.72,
            initialSpringVelocity: 0.85,
            options: [.curveEaseOut]
        ) {
            self.card.alpha = 1
            self.card.transform = .identity
        }

        UIView.animate(
            withDuration: 0.58,
            delay: 0.12,
            usingSpringWithDamping: 0.48,
            initialSpringVelocity: 0.95,
            options: [.curveEaseOut]
        ) {
            self.iconBadge.transform = .identity
        } completion: { _ in
            self.startPulse()
            if self.style == .warning {
                self.shakeCard()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            switch self.style {
            case .info:
                TapticEngine.impact.feedback(.medium)
            case .warning:
                TapticEngine.notification.feedback(.warning)
            case .success:
                TapticEngine.notification.feedback(.success)
            }
        }
    }

    private func startPulse() {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 0.92
        scale.toValue = 1.18

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0.7
        fade.toValue = 0

        let group = CAAnimationGroup()
        group.animations = [scale, fade]
        group.duration = 1.35
        group.repeatCount = .infinity
        group.timingFunction = CAMediaTimingFunction(name: .easeOut)
        pulseRing.add(group, forKey: "pulse")
    }

    private func shakeCard() {
        let shake = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shake.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        shake.duration = 0.42
        shake.values = [0, -10, 10, -7, 7, -3, 3, 0]
        card.layer.add(shake, forKey: "shake")
    }

    @objc private func dimTapped() {
        TapticEngine.impact.feedback(.light)
        let handler = onAction
        dismiss { handler?() }
    }

    @objc private func actionTapped() {
        TapticEngine.impact.feedback(.medium)
        let handler = onAction
        dismiss {
            handler?()
        }
    }

    private func dismiss(completion: (() -> Void)? = nil) {
        pulseRing.removeAllAnimations()
        UIView.animate(
            withDuration: 0.22,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.dimView.alpha = 0
            self.card.alpha = 0
            self.card.transform = CGAffineTransform(translationX: 0, y: 18).scaledBy(x: 0.92, y: 0.92)
        } completion: { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}
