import UIKit

final class SignUpViewController: UIViewController {
    @IBOutlet private weak var logoContainer: UIView!
    @IBOutlet private weak var phoneContainer: UIView!
    @IBOutlet private weak var flagImageView: UIImageView!
    @IBOutlet private weak var countryCodeLabel: UILabel!
    @IBOutlet private weak var phoneTextField: UITextField!
    @IBOutlet private weak var sendButton: GoldGradientButton!

    private let dialCode = "+971"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        phoneContainer?.layer.borderColor = AppPalette.separator.cgColor
        phoneContainer?.clipsToBounds = true

        phoneTextField?.attributedPlaceholder = NSAttributedString(
            string: "Enter mobile number",
            attributes: [.foregroundColor: AppPalette.secondaryText]
        )
        phoneTextField?.tintColor = AppPalette.gold

        sendButton?.layer.cornerRadius = 14
        sendButton?.clipsToBounds = true

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
    }

    @IBAction private func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction private func helpTapped(_ sender: Any) {
        showAlert(title: "Help", message: "Enter your mobile number to receive a one-time verification code.")
    }

    @IBAction private func sendOTPTapped(_ sender: Any) {
        let phone = (phoneTextField?.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !phone.isEmpty else {
            showAlert(message: "Please enter your phone number.")
            return
        }
        let otp = UIStoryboard.authOTP
            .instantiateViewController(withIdentifier: "EnterOTPVC") as! EnterOTPVC
        otp.phoneNumberDisplay = "\(dialCode) \(phone)"
        navigationController?.pushViewController(otp, animated: true)
    }
}
