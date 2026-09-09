import UIKit

final class EnterOTPVC: UIViewController {
    var phoneNumberDisplay: String = ""

    private let topBar = AuthTopBar()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let otpView = AuthOTPView()
    private let resendLabel = UILabel()

    private var secondsRemaining = 25
    private var timer: Timer?
    private var didAdvance = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = AppPalette.background
        authDismissKeyboardOnTap()
        buildUI()
        startResendTimer()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        otpView.focus()
    }

    deinit {
        timer?.invalidate()
    }

    private func buildUI() {
        topBar.showsHelp = false
        topBar.showsLogo = true
        topBar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Enter the 6-digit code"
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 0

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "We sent a verification code to \(phoneNumberDisplay)"
        subtitleLabel.textColor = AppPalette.secondaryText
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.numberOfLines = 0

        otpView.delegate = self

        resendLabel.translatesAutoresizingMaskIntoConstraints = false
        resendLabel.numberOfLines = 0
        resendLabel.isUserInteractionEnabled = true
        resendLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendTapped)))

        view.addSubview(topBar)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(otpView)
        view.addSubview(resendLabel)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthMetrics.gutter),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuthMetrics.gutter),

            titleLabel.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthMetrics.gutter),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuthMetrics.gutter),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            otpView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 32),
            otpView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            otpView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            resendLabel.topAnchor.constraint(equalTo: otpView.bottomAnchor, constant: 24),
            resendLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            resendLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])

        updateResendLabel()
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func resendTapped() {
        guard secondsRemaining <= 0 else { return }
        startResendTimer()
    }

    private func startResendTimer() {
        timer?.invalidate()
        secondsRemaining = 25
        updateResendLabel()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.secondsRemaining -= 1
            self.updateResendLabel()
            if self.secondsRemaining <= 0 {
                self.timer?.invalidate()
            }
        }
    }

    private func updateResendLabel() {
        let prefix = "Didn't receive the code? "
        let suffix: String
        if secondsRemaining > 0 {
            let minutes = secondsRemaining / 60
            let seconds = secondsRemaining % 60
            suffix = String(format: "Resend in %02d:%02d", minutes, seconds)
        } else {
            suffix = "Resend"
        }
        let text = NSMutableAttributedString(
            string: prefix,
            attributes: [
                .foregroundColor: AppPalette.secondaryText,
                .font: UIFont.systemFont(ofSize: 14, weight: .regular)
            ]
        )
        text.append(NSAttributedString(
            string: suffix,
            attributes: [
                .foregroundColor: AppPalette.gold,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        ))
        resendLabel.attributedText = text
    }

    private func advance() {
        guard !didAdvance else { return }
        didAdvance = true
        navigationController?.pushViewController(EnterEmailVC(), animated: true)
    }
}

extension EnterOTPVC: AuthOTPViewDelegate {
    func authOTPViewDidComplete(_ code: String) {
        advance()
    }
}
