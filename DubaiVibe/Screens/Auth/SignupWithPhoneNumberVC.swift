import UIKit

final class SignupWithPhoneNumberVC: UIViewController {
    @IBOutlet private weak var logoContainer: UIView!
    @IBOutlet private weak var phoneContainer: UIView!
    @IBOutlet private weak var flagImageView: UIImageView!
    @IBOutlet private weak var countryCodeLabel: UILabel!
    @IBOutlet private weak var phoneTextField: UITextField!
    @IBOutlet private weak var sendButton: GoldGradientButton!
    @IBOutlet private weak var contentScrollView: UIScrollView?

    private let dialCode = "+971"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        phoneContainer?.layer.borderColor = AppPalette.separator.cgColor
        phoneContainer?.clipsToBounds = true

        phoneTextField?.tintColor = AppPalette.gold
        phoneTextField?.keyboardType = .phonePad
        phoneTextField?.textContentType = .telephoneNumber
        phoneTextField?.delegate = self
        phoneTextField?.enablePhoneNumberFormattingFortextField(countryCode: "AE")
        if let contentScrollView {
            pinAuthScrollViewToKeyboard(contentScrollView)
        }

        sendButton?.layer.cornerRadius = 14
        sendButton?.clipsToBounds = true
        sendButton?.setTitle(L10n.sendOTP, for: .normal)

        countryCodeLabel?.text = dialCode
        if let flag = UIImage(
            named: "assets.bundle/AE.png",
            in: Bundle(for: TDCountryPicker.self),
            compatibleWith: nil
        ) {
            flagImageView?.image = flag
            flagImageView?.tintColor = nil
        }

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        applyLocalizedStoryboardCopy()
        phoneTextField?.attributedPlaceholder = NSAttributedString(
            string: "50 123 4567",
            attributes: [.foregroundColor: AppPalette.secondaryText]
        )
    }

    @IBAction private func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func helpTapped(_ sender: Any) {
        showAlert(title: L10n.help, message: L10n.phoneHelpMessage)
    }

    @IBAction private func sendOTPTapped(_ sender: Any) {
        let phone = (phoneTextField?.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phone.isEmpty else {
            showAlert(message: L10n.enterPhoneNumber)
            return
        }
        guard phone.isValidUAEMobileNumber else {
            showAlert(message: L10n.invalidUAEPhoneNumber)
            return
        }
        let formattedLocal = phone.uaeFormattedPhoneNumber
        phoneTextField?.text = formattedLocal
        let otp = UIStoryboard.authentication
            .instantiateViewController(withIdentifier: "EnterOTPVC") as! EnterOTPVC
        otp.phoneNumberDisplay = "\(dialCode) \(formattedLocal)"
        navigationController?.pushViewController(otp, animated: true)
    }
}

extension SignupWithPhoneNumberVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty { return true }

        let allowed = CharacterSet.decimalDigits
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "+-()"))
        guard string.unicodeScalars.allSatisfy({ allowed.contains($0) }) else {
            return false
        }

        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else { return false }
        let updated = current.replacingCharacters(in: textRange, with: string)
        return updated.uaeStrippedMobileDigits.count <= 9
    }
}
