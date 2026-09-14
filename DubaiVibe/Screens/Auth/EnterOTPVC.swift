import UIKit

final class EnterOTPVC: UIViewController {
    var phoneNumberDisplay: String = ""
    var phoneCode: String = "+971"
    var phoneNumber: String = ""
    var debugOTPCode: String?

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var otpView: AuthOTPView!
    @IBOutlet private weak var resendLabel: UILabel!

    private let viewModel = AuthViewModel()
    private var secondsRemaining = 60
    private var timer: Timer?
    private var didAdvance = false
    private var isSubmitting = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        authDismissKeyboardOnTap()

        configureSubtitle()
        otpView?.delegate = self
        resendLabel?.isUserInteractionEnabled = true
        resendLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendTapped)))

        startResendTimer()
        #if DEBUG
        if let debugOTPCode, !debugOTPCode.isEmpty {
            print("OTP debugCode:", debugOTPCode)
        }
        #endif
    }

    private func configureSubtitle() {
        let prefix = "We sent a verification code to\n"
        let phone = phoneNumberDisplay.isEmpty ? "" : phoneNumberDisplay
        let text = NSMutableAttributedString(
            string: prefix,
            attributes: [
                .foregroundColor: AppPalette.secondaryText,
                .font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )
        text.append(NSAttributedString(
            string: phone,
            attributes: [
                .foregroundColor: AppPalette.secondaryText,
                .font: UIFont.systemFont(ofSize: 15, weight: .bold)
            ]
        ))
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = subtitleLabel?.textAlignment ?? .center
        text.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: text.length))
        subtitleLabel?.attributedText = text
        subtitleLabel?.numberOfLines = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        otpView?.focus()
    }

    deinit {
        timer?.invalidate()
    }

    @IBAction private func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func resendTapped() {
        guard secondsRemaining <= 0 else { return }
        viewModel.resendPhoneOTP(phoneCode: phoneCode, phone: phoneNumber) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.showSuccessToast(response.message, fallback: "OTP sent")
                self.otpView?.clear()
                self.otpView?.focus()
                self.startResendTimer()
                #if DEBUG
                if let code = response.data?.debugCode, !code.isEmpty {
                    self.debugOTPCode = code
                    print("OTP debugCode:", code)
                }
                #endif
            case .failure(let error):
                self.showErrorPopup(error)
            }
        }
    }

    private func startResendTimer() {
        timer?.invalidate()
        secondsRemaining = 60
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
                .font: UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium),
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        ))
        resendLabel?.attributedText = text
    }

    private func verify(code: String) {
        guard !isSubmitting, !didAdvance else { return }
        isSubmitting = true
        viewModel.verifyPhoneOTP(
            phoneCode: phoneCode,
            phone: phoneNumber,
            code: code
        ) { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            switch result {
            case .success(let response):
                self.showSuccessToast(response.message, fallback: "OTP verified")
                self.didAdvance = true
                AppRouter.continueAfterLogin(from: self, user: response.resolvedUser)
            case .failure(let error):
                self.showErrorPopup(error)
                self.otpView?.clear()
                self.otpView?.focus()
            }
        }
    }
}

extension EnterOTPVC: AuthOTPViewDelegate {
    func authOTPViewDidComplete(_ code: String) {
        verify(code: code)
    }
}
