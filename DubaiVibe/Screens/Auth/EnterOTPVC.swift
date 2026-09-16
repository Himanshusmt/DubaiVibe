import UIKit

final class EnterOTPVC: UIViewController {
    var phoneNumberDisplay: String = ""
    var phoneCode: String = "+971"
    var phoneNumber: String = ""
    var debugOTPCode: String?

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var otpView: AuthOTPView!
    @IBOutlet private weak var verifyButton: GoldGradientButton!
    @IBOutlet private weak var resendLabel: UILabel!
    @IBOutlet private weak var contentScrollView: UIScrollView?

    private let viewModel = AuthViewModel()
    private var secondsRemaining = 60
    private var timer: Timer?
    private var didAdvance = false
    private var isSubmitting = false
    private var didScheduleDebugOTPAutofill = false

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        authDismissKeyboardOnTap()

        configureSubtitle()
        otpView?.delegate = self
        if let contentScrollView {
            pinAuthScrollViewToKeyboard(contentScrollView)
        }
        resendLabel?.isUserInteractionEnabled = true
        resendLabel?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resendTapped)))

        verifyButton?.layer.cornerRadius = 14
        verifyButton?.clipsToBounds = true
        verifyButton?.setTitle(L10n.verifyOTP, for: .normal)
        updateVerifyButtonState()

        startResendTimer()
        applyLocalizedStoryboardCopy()
    }

    private func configureSubtitle() {
        titleLabel?.text = L10n.otpTitle
        let prefix = L10n.otpSentPrefix
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
        scheduleDebugOTPAutofillIfNeeded()
    }

    deinit {
        timer?.invalidate()
    }

    /// Temporary helper: toast the API OTP, then auto-fill after 1s so QA can proceed quickly.
    private func scheduleDebugOTPAutofillIfNeeded(force: Bool = false) {
        guard let code = debugOTPCode?.trimmingCharacters(in: .whitespacesAndNewlines),
              !code.isEmpty else { return }
        if !force {
            guard !didScheduleDebugOTPAutofill else { return }
            didScheduleDebugOTPAutofill = true
        }

        UIPasteboard.general.string = code
        showSuccessToast("OTP copied: \(code)", fallback: "OTP copied: \(code)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self, !self.didAdvance else { return }
            self.otpView?.fill(code)
            self.updateVerifyButtonState()
        }
    }

    @IBAction private func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func verifyTapped(_ sender: Any) {
        view.endEditing(true)
        let code = otpView?.code ?? ""
        guard code.count == 6 else {
            showAlert(message: L10n.enterOTPCode)
            return
        }
        verify(code: code)
    }

    @objc private func resendTapped() {
        guard secondsRemaining <= 0 else { return }
        viewModel.resendPhoneOTP(phoneCode: phoneCode, phone: phoneNumber) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.otpView?.clear()
                self.updateVerifyButtonState()
                self.otpView?.focus()
                self.startResendTimer()
                if let code = response.data?.debugCode, !code.isEmpty {
                    self.debugOTPCode = code
                    self.scheduleDebugOTPAutofillIfNeeded(force: true)
                } else {
                    self.showSuccessToast(response.message, fallback: "OTP sent")
                }
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
        let prefix = L10n.otpDidntReceive
        let suffix: String
        if secondsRemaining > 0 {
            let minutes = secondsRemaining / 60
            let seconds = secondsRemaining % 60
            suffix = L10n.otpResendIn(minutes: minutes, seconds: seconds)
        } else {
            suffix = L10n.otpResend
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

    private func updateVerifyButtonState() {
        let isReady = (otpView?.code.count ?? 0) == 6
        verifyButton?.isEnabled = isReady
        verifyButton?.alpha = isReady ? 1 : 0.5
    }
    
    private func verify(code: String) {
        guard !isSubmitting, !didAdvance else { return }
        isSubmitting = true
        verifyButton?.isEnabled = false
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
                AppRouter.continueAfterLogin(
                    from: self,
                    user: response.resolvedUser,
                    isOnboardingComplete: response.resolvedOnboardingFlag
                )
            case .failure(let error):
                self.showErrorPopup(error)
                self.otpView?.clear()
                self.updateVerifyButtonState()
                self.otpView?.focus()
            }
        }
    }
}

extension EnterOTPVC: AuthOTPViewDelegate {
    func authOTPViewDidChangeCode(_ code: String) {
        updateVerifyButtonState()
    }

    func authOTPViewDidComplete(_ code: String) {
        updateVerifyButtonState()
    }
}
