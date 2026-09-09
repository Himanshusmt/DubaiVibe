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
        logoTileView.layer.cornerRadius = 12
        logoTileView.layer.cornerCurve = .continuous
//        logoTileView.layer.borderWidth = 1.4
//        logoTileView.layer.borderColor = AppPalette.gold.cgColor
        logoTileView.clipsToBounds = true
        logoImageView.image = UIImage(named: "LaunchLogo")
        logoImageView.contentMode = .scaleAspectFit

        profileImageView.image = Self.memberAvatar()
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

        codeCardView.backgroundColor = UIColor(hex: 0x0C0B09)
        codeCardView.layer.cornerRadius = 22
        codeCardView.layer.cornerCurve = .continuous
        codeCardView.layer.borderWidth = 1
        codeCardView.layer.borderColor = AppPalette.gold.withAlphaComponent(0.9).cgColor
        codeCardView.layer.shadowColor = AppPalette.gold.cgColor
        codeCardView.layer.shadowOpacity = 0.28
        codeCardView.layer.shadowRadius = 16
        codeCardView.clipsToBounds = false

        detailsPanelView.backgroundColor = UIColor(hex: 0x161410)
        detailsPanelView.layer.cornerRadius = 16
        detailsPanelView.layer.cornerCurve = .continuous
        detailsPanelView.layer.borderWidth = 0.5
        detailsPanelView.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor

        sparkleLeftStack.transform = CGAffineTransform(rotationAngle: -0.42)
        sparkleRightStack.transform = CGAffineTransform(rotationAngle: 0.42)

        captionLabel.attributedText = NSAttributedString(string: "YOUR VERIFIED CODE", attributes: [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: AppPalette.gold,
            .kern: 1.8
        ])

        codeBarView.backgroundColor = UIColor(hex: 0x1C1A16)
        codeBarView.layer.cornerRadius = 12
        codeBarView.layer.cornerCurve = .continuous
        codeLabel.textAlignment = .center

        let copyConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        copyButton.setImage(UIImage(systemName: "square.on.square", withConfiguration: copyConfig), for: .normal)
        copyButton.tintColor = AppPalette.primaryText
    }

    func bindVoucher(issuedAt: Date) {
        self.issuedAt = issuedAt
        voucherCode = Self.makeCode()
        let expires = issuedAt.addingTimeInterval(Metric.validity)

        nameLabel.text = "Alex R."
        memberSinceLabel.text = "OneVibe Member since 2024"
        codeLabel.text = voucherCode
        dateValueLabel.text = Self.dateFormatter.string(from: issuedAt)
        timeValueLabel.text = Self.timeFormatter.string(from: issuedAt)
        validUntilValueLabel.text = Self.untilFormatter.string(from: expires)
        validForValueLabel.attributedText = {
            let text = NSMutableAttributedString(
                string: "15 ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                    .foregroundColor: UIColor.white
                ]
            )
            text.append(NSAttributedString(
                string: "minutes",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .semibold),
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
        UIPasteboard.general.string = voucherCode
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        let check = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        copyButton.setImage(UIImage(systemName: "checkmark", withConfiguration: check), for: .normal)
        copyButton.tintColor = AppPalette.gold
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            let copy = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            self?.copyButton.setImage(UIImage(systemName: "square.on.square", withConfiguration: copy), for: .normal)
            self?.copyButton.tintColor = AppPalette.primaryText
        }
    }
}
