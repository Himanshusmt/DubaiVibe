import UIKit

/// Welcome / auth entry screen. Layout and button chrome live in Authentication.storyboard.
final class WelcomeVC: UIViewController {
    @IBOutlet private weak var termsTextView: UITextView!

    private enum Link {
        static let terms = URL(string: "dubaivibe://terms")!
        static let privacy = URL(string: "dubaivibe://privacy")!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureTermsLinks()
    }

    /// Attributed links can't be authored fully in IB — only this bit stays in code.
    private func configureTermsLinks() {
        guard let termsTextView else { return }

        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let text = NSMutableAttributedString(
            string: "By continuing, you agree to our ",
            attributes: [
                .foregroundColor: AppPalette.secondaryText,
                .font: font,
                .paragraphStyle: paragraph
            ]
        )
        text.append(NSAttributedString(
            string: "Terms of Service",
            attributes: [
                .link: Link.terms,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .paragraphStyle: paragraph
            ]
        ))
        text.append(NSAttributedString(
            string: " and ",
            attributes: [
                .foregroundColor: AppPalette.secondaryText,
                .font: font,
                .paragraphStyle: paragraph
            ]
        ))
        text.append(NSAttributedString(
            string: "Privacy Policy",
            attributes: [
                .link: Link.privacy,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .paragraphStyle: paragraph
            ]
        ))
        text.append(NSAttributedString(
            string: ".",
            attributes: [
                .foregroundColor: AppPalette.secondaryText,
                .font: font,
                .paragraphStyle: paragraph
            ]
        ))

        termsTextView.attributedText = text
        termsTextView.linkTextAttributes = [
            .foregroundColor: AppPalette.gold,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        termsTextView.delegate = self
        termsTextView.textContainerInset = .zero
        termsTextView.textContainer.lineFragmentPadding = 0
    }

    @IBAction private func continueWithPhone(_ sender: Any) {
        // TODO: Phone authentication — UI navigation stub only.
        let phone = UIStoryboard.authPhone
            .instantiateViewController(withIdentifier: "SignUpViewController")
        navigationController?.pushViewController(phone, animated: true)
    }

    @IBAction private func continueWithApple(_ sender: Any) {
        // TODO: Sign in with Apple — UI navigation stub only.
        navigationController?.pushViewController(EnterEmailVC(), animated: true)
    }

    @IBAction private func continueWithGoogle(_ sender: Any) {
        // TODO: Google Sign-In — UI navigation stub only.
        navigationController?.pushViewController(EnterEmailVC(), animated: true)
    }
}

extension WelcomeVC: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        switch URL {
        case Link.terms:
            showAlert(title: "Terms of Service", message: "Terms of Service will be available soon.")
        case Link.privacy:
            showAlert(title: "Privacy Policy", message: "Privacy Policy will be available soon.")
        default:
            break
        }
        return false
    }
}
