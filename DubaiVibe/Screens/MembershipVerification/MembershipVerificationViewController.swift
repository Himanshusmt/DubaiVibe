import UIKit

final class MembershipVerificationViewController: UIViewController {
    private enum Metric {
        static let validity: TimeInterval = 15 * 60
    }

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

    private var voucherCode = "OV-7K92X4"
    private var issuedAt = Date()
    private var lastCopyAt: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureChrome()
        bindVoucher(issuedAt: Date())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
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
        helpButton.setTitleColor(AppPalette.gold, for: .normal)
        helpButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        logoTileView.backgroundColor = .black
//        logoTileView.layer.cornerRadius = 12
        logoTileView.layer.cornerCurve = .continuous
//        logoTileView.layer.borderWidth = 1.4
//        logoTileView.layer.borderColor = AppPalette.gold.cgColor
        logoTileView.clipsToBounds = true
        logoImageView.image = UIImage(named: "LaunchLogo")
        logoImageView.contentMode = .scaleAspectFit

        profileImageView.image = UIImage(named: "MemberAvatar") ?? Self.memberAvatar()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.borderWidth = 3
        profileImageView.layer.borderColor = AppPalette.gold.cgColor

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
        // The design keeps the area just outside the card pure black, so no outer bloom.
        codeCardView.layer.shadowOpacity = 0
        codeCardView.clipsToBounds = false

        detailsPanelView.backgroundColor = UIColor(hex: 0x060505)
        detailsPanelView.layer.cornerRadius = 16
        detailsPanelView.layer.cornerCurve = .continuous
        detailsPanelView.layer.borderWidth = 0.5
        detailsPanelView.layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor

        // The dashes radiate away from the shield; Interface Builder can't set a rotation.
        angleSparkles(in: sparkleLeftStack, clockwiseFirst: true)
        angleSparkles(in: sparkleRightStack, clockwiseFirst: false)

        captionLabel.attributedText = NSAttributedString(string: "YOUR VERIFIED CODE", attributes: [
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

    /// Tilts a sparkle stack's two dashes so they point away from the shield.
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
        copyButton.accessibilityLabel = "Copy code"
        copyButton.accessibilityHint = "Copies the verified membership code"
        copyButton.isUserInteractionEnabled = true
        copyButton.isExclusiveTouch = true
        codeBarView.bringSubviewToFront(copyButton)

        if codeBarView.gestureRecognizers?.contains(where: { $0.name == "copy-code" }) != true {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleCopyCode))
            tap.name = "copy-code"
            codeBarView.addGestureRecognizer(tap)
        }
    }

    func bindVoucher(issuedAt: Date) {
        self.issuedAt = issuedAt
        voucherCode = "OV-7K92X4"
        let expires = issuedAt.addingTimeInterval(Metric.validity)

        nameLabel.text = "Alex R."
        memberSinceLabel.text = "OneVibe Member since 2024"
        codeLabel.attributedText = NSAttributedString(string: voucherCode, attributes: [
            .font: AppTypography.font(.bold, size: 24),
            .foregroundColor: UIColor.white,
            .kern: 3.0
        ])
        codeLabel.textAlignment = .center
        dateValueLabel.text = Self.dateFormatter.string(from: issuedAt)
        timeValueLabel.text = Self.timeFormatter.string(from: issuedAt)
        validUntilValueLabel.text = Self.untilFormatter.string(from: expires)
        validForValueLabel.attributedText = {
            let text = NSMutableAttributedString(
                string: "15 ",
                attributes: [
                    .font: AppTypography.font(.bold, size: 15),
                    .foregroundColor: UIColor.white
                ]
            )
            text.append(NSAttributedString(
                string: "minutes",
                attributes: [
                    .font: AppTypography.font(.semibold, size: 15),
                    .foregroundColor: UIColor.white
                ]
            ))
            return text
        }()
        usageValueLabel.text = "One-time use only"
    }

    static func makeCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        let body = String((0..<6).map { _ in alphabet.randomElement()! })
        return "OV-\(body)"
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
        formatter.locale = Locale(identifier: "en_GB")
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
        formatter.locale = Locale(identifier: "en_GB")
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
        let alert = UIAlertController(
            title: "Help",
            message: "Show this verified code to venue staff to redeem your OneVibe exclusive. The code expires in 15 minutes and can only be used once.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func handleCopyCode() {
        let now = ProcessInfo.processInfo.systemUptime
        guard now - lastCopyAt > 0.35 else { return }
        lastCopyAt = now

        let code = codeLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let value = (code?.isEmpty == false ? code : voucherCode) ?? voucherCode
        UIPasteboard.general.string = value
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIAccessibility.post(notification: .announcement, argument: "Code copied")

        configureCopyButton(icon: "checkmark", tint: AppPalette.gold, weight: .semibold)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.configureCopyButton()
        }
    }
}
