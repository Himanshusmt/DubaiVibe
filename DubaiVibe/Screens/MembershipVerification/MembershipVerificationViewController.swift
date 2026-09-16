import UIKit

final class MembershipVerificationViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var helpButton: UIButton!
    @IBOutlet private weak var logoTileView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var crownBadgeView: UIView!
    @IBOutlet private weak var verifiedBadgeView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var memberSinceLabel: UILabel!
    @IBOutlet private weak var codeCardView: UIView!
    @IBOutlet private weak var detailsPanelView: UIView!
    @IBOutlet private weak var sparkleLeftStack: UIStackView!
    @IBOutlet private weak var sparkleRightStack: UIStackView!
    @IBOutlet private weak var captionLabel: UILabel!
    @IBOutlet private weak var codeBarView: UIView!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var copyButton: UIButton!
    @IBOutlet private weak var dateValueLabel: UILabel!
    @IBOutlet private weak var timeValueLabel: UILabel!
    @IBOutlet private weak var validUntilValueLabel: UILabel!
    @IBOutlet private weak var validForValueLabel: UILabel!
    @IBOutlet private weak var usageValueLabel: UILabel!

    private var redemption: UnlockOfferData?
    private var voucherCode = ""
    private var lastCopyAt: TimeInterval = 0
    private var hasCopiedCode = false

    /// Call before push / present with the unlock API payload.
    func configure(with redemption: UnlockOfferData) {
        self.redemption = redemption
        if isViewLoaded {
            bindRedemption(redemption)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureChrome()
        applyLocalizedStoryboardCopy()
        if let redemption {
            bindRedemption(redemption)
        } else {
            bindLocalProfileOnly()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if hasCopiedCode {
            hasCopiedCode = false
            configureCopyButton()
        }
    }
}

private extension MembershipVerificationViewController {
    func configureChrome() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        let chevron = UIImage.SymbolConfiguration(pointSize: 17, weight: .regular)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevron), for: .normal)
        backButton.tintColor = AppPalette.gold
        helpButton.setTitle(L10n.help, for: .normal)
        helpButton.setTitleColor(AppPalette.gold, for: .normal)
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        logoTileView.backgroundColor = .black
        logoTileView.layer.cornerCurve = .continuous
        logoTileView.clipsToBounds = true
        logoImageView.image = UIImage(named: "LaunchLogo")
        logoImageView.contentMode = .scaleAspectFit

        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = AppPalette.gold.cgColor
        applyLocalProfileImage()

        crownBadgeView.backgroundColor = AppPalette.gold
        (crownBadgeView.subviews.first as? UIImageView)?.tintColor = .black

        verifiedBadgeView.backgroundColor = .black
        verifiedBadgeView.layer.cornerRadius = 14
        verifiedBadgeView.layer.cornerCurve = .continuous
        verifiedBadgeView.layer.borderWidth = 1
        verifiedBadgeView.layer.borderColor = AppPalette.gold.cgColor

        nameLabel.font = AppTypography.font(.bold, size: 20)
        memberSinceLabel.font = AppTypography.font(.regular, size: 13)
        memberSinceLabel.textColor = AppPalette.secondaryText

        codeCardView.backgroundColor = UIColor(hex: 0x0A0908)
        codeCardView.layer.cornerRadius = 22
        codeCardView.layer.cornerCurve = .continuous
        codeCardView.layer.borderWidth = 1
        codeCardView.layer.borderColor = AppPalette.gold.withAlphaComponent(0.55).cgColor
        codeCardView.layer.shadowOpacity = 0
        codeCardView.clipsToBounds = false

        detailsPanelView.backgroundColor = UIColor(hex: 0x060505)
        detailsPanelView.layer.cornerRadius = 16
        detailsPanelView.layer.cornerCurve = .continuous
        detailsPanelView.layer.borderWidth = 0.5
        detailsPanelView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        angleSparkles(in: sparkleLeftStack, clockwiseFirst: true)
        angleSparkles(in: sparkleRightStack, clockwiseFirst: false)

        captionLabel.attributedText = NSAttributedString(string: L10n.yourVerifiedCode, attributes: [
            .font: AppTypography.font(.semibold, size: 11),
            .foregroundColor: AppPalette.gold,
            .kern: 2.4
        ])

        codeBarView.backgroundColor = UIColor(hex: 0x111112)
        codeBarView.layer.cornerRadius = 12
        codeBarView.layer.cornerCurve = .continuous
        codeBarView.clipsToBounds = true
        codeBarView.isUserInteractionEnabled = true
        codeLabel.textAlignment = .center
        codeLabel.isUserInteractionEnabled = false

        configureCopyButton()
    }

    func angleSparkles(in stack: UIStackView, clockwiseFirst: Bool) {
        let tilt = 25.0 * .pi / 180.0
        for (index, dash) in stack.arrangedSubviews.enumerated() {
            let clockwise = (index == 0) == clockwiseFirst
            dash.transform = CGAffineTransform(rotationAngle: clockwise ? tilt : -tilt)
        }
    }

    func configureCopyButton(icon: String = "square.on.square", tint: UIColor = AppPalette.primaryText, weight: UIImage.SymbolWeight = .medium) {
        let symbol = UIImage.SymbolConfiguration(pointSize: 16, weight: weight)
        copyButton.setImage(UIImage(systemName: icon, withConfiguration: symbol), for: .normal)
        copyButton.tintColor = tint
        copyButton.accessibilityLabel = L10n.copyCode
        copyButton.accessibilityHint = L10n.copyCodeHint
        copyButton.isUserInteractionEnabled = true
        copyButton.isExclusiveTouch = true
        copyButton.isEnabled = true
        codeBarView.bringSubviewToFront(copyButton)

        copyButton.removeTarget(self, action: #selector(handleCopyCode), for: .touchUpInside)
        copyButton.addTarget(self, action: #selector(handleCopyCode), for: .touchUpInside)

        if codeBarView.gestureRecognizers?.contains(where: { $0.name == "copy-code" }) != true {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCopyCode))
            tap.name = "copy-code"
            tap.cancelsTouchesInView = false
            codeBarView.addGestureRecognizer(tap)
        }
    }

    func bindLocalProfileOnly() {
        nameLabel.text = LocalUserStore.membershipDisplayName
        memberSinceLabel.text = L10n.memberSince(2024)
        applyLocalProfileImage()
        usageValueLabel.text = L10n.oneTimeUse
    }

    func bindRedemption(_ data: UnlockOfferData) {
        let issuedAt = data.redeemedDate
        let validUntil = data.validUntilDate
        let minutes = max(data.validityMinutes ?? 15, 1)
        voucherCode = data.resolvedCode

        let locale = LocalizationManager.shared.locale
        Self.dateFormatter.locale = locale
        Self.timeFormatter.locale = locale
        Self.untilFormatter.locale = locale

        nameLabel.text = LocalUserStore.membershipDisplayName
        memberSinceLabel.text = L10n.memberSince(2024)
        applyLocalProfileImage()

        codeLabel.attributedText = NSAttributedString(string: voucherCode, attributes: [
            .font: AppTypography.font(.bold, size: 24),
            .foregroundColor: UIColor.white,
            .kern: 3.0
        ])
        codeLabel.textAlignment = .center
        dateValueLabel.text = Self.dateFormatter.string(from: issuedAt)
        timeValueLabel.text = Self.timeFormatter.string(from: issuedAt)
        validUntilValueLabel.text = Self.untilFormatter.string(from: validUntil)
        validForValueLabel.attributedText = {
            let text = NSMutableAttributedString(
                string: "\(minutes) ",
                attributes: [
                    .font: AppTypography.font(.bold, size: 15),
                    .foregroundColor: UIColor.white
                ]
            )
            text.append(NSAttributedString(
                string: L10n.minutes,
                attributes: [
                    .font: AppTypography.font(.semibold, size: 15),
                    .foregroundColor: UIColor.white
                ]
            ))
            return text
        }()
        usageValueLabel.text = L10n.oneTimeUse
    }

    func applyLocalProfileImage() {
        let placeholder = UIImage(named: "avatarIcon") ?? UIImage(named: "p1") ?? Self.memberAvatar()
        if let remote = LocalUserStore.avatarURL, !remote.isEmpty {
            profileImageView.setBusinessImage(urlString: remote, placeholder: placeholder)
            profileImageView.contentMode = .scaleAspectFill
        } else if let local = LocalUserStore.localAvatarImage {
            profileImageView.image = local
            profileImageView.contentMode = .scaleAspectFill
        } else {
            profileImageView.image = placeholder
            profileImageView.contentMode = .scaleAspectFill
        }
    }

    static func memberAvatar() -> UIImage {
        let size = CGSize(width: 184, height: 184)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let bounds = CGRect(origin: .zero, size: size)
            UIColor(hex: 0x3B2A22).setFill()
            UIBezierPath(ovalIn: bounds).fill()

            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(hex: 0x5A3F32).cgColor,
                    UIColor(hex: 0x2A1C16).cgColor
                ] as CFArray,
                locations: [0, 1]
            )
            if let gradient {
                ctx.cgContext.drawRadialGradient(
                    gradient,
                    startCenter: CGPoint(x: 78, y: 62),
                    startRadius: 8,
                    endCenter: CGPoint(x: 92, y: 92),
                    endRadius: 110,
                    options: [.drawsAfterEndLocation]
                )
            }

            let config = UIImage.SymbolConfiguration(pointSize: 92, weight: .regular)
            if let person = UIImage(systemName: "person.fill", withConfiguration: config)?
                .withTintColor(UIColor(hex: 0xD4B08C), renderingMode: .alwaysOriginal) {
                person.draw(in: CGRect(x: 40, y: 46, width: 104, height: 118))
            }
        }
    }

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.shared.locale
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "HH:mm (h:mm a)"
        return formatter
    }()

    static let untilFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.shared.locale
        formatter.dateFormat = "d MMM yyyy, HH:mm"
        return formatter
    }()
}

// MARK: - Actions

private extension MembershipVerificationViewController {
    @IBAction func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func handleHelp() {
        showAnimatedAlert(
            title: L10n.help,
            message: L10n.membershipHelp,
            style: .info
        )
    }

    @IBAction @objc func handleCopyCode() {
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastCopyAt > 0.35 else { return }
        lastCopyAt = now

        let labeled = codeLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let value = !voucherCode.isEmpty ? voucherCode : labeled
        guard !value.isEmpty else { return }

        UIPasteboard.general.string = value
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIAccessibility.post(notification: .announcement, argument: L10n.codeCopied)
        showSuccessToast(L10n.codeCopied, fallback: "Code copied")

        hasCopiedCode = true
        configureCopyButton(icon: "checkmark", tint: AppPalette.gold, weight: .semibold)
    }
}
