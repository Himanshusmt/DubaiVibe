import UIKit

/// Welcome / auth entry screen. Layout and button chrome live in Authentication.storyboard.
final class SignupOptionsVC: UIViewController {
    @IBOutlet private weak var phoneButton: GoldGradientButton!
    @IBOutlet private weak var termsTextView: UITextView!

    private let appleSignIn = AppleSignInService()
    private let googleSignIn = GoogleSignInService()
    private let viewModel = AuthViewModel()

    private enum Link {
        static let terms = URL(string: "dubaivibe://terms")!
        static let privacy = URL(string: "dubaivibe://privacy")!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        phoneButton?.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        phoneButton?.setTitle(L10n.continueWithPhone, for: .normal)
        applyLocalizedStoryboardCopy()
        configureTermsLinks()
    }

    /// Attributed links can't be authored fully in IB — only this bit stays in code.
    private func configureTermsLinks() {
        guard let termsTextView else { return }

        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let text = NSMutableAttributedString(
            string: L10n.termsPrefix,
            attributes: [
                .foregroundColor: AppPalette.secondaryText,
                .font: font,
                .paragraphStyle: paragraph
            ]
        )
        text.append(NSAttributedString(
            string: L10n.termsOfService,
            attributes: [
                .link: Link.terms,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .paragraphStyle: paragraph
            ]
        ))
        text.append(NSAttributedString(
            string: L10n.termsAnd,
            attributes: [
                .foregroundColor: AppPalette.secondaryText,
                .font: font,
                .paragraphStyle: paragraph
            ]
        ))
        text.append(NSAttributedString(
            string: L10n.privacyPolicy,
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
        guard let phone = UIStoryboard.authentication
            .instantiateViewController(withIdentifier: "SignupWithPhoneNumberVC") as? SignupWithPhoneNumberVC
        else { return }
        navigationController?.pushViewController(phone, animated: true)
    }

    @IBAction private func continueWithApple(_ sender: Any) {
        appleSignIn.signIn(from: self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let credential):
                self.handleAppleCredential(credential)
            case .failure(.canceled):
                break
            case .failure(let error):
                if let message = error.errorDescription, !message.isEmpty {
                    self.showAlert(message: message)
                }
            }
        }
    }

    @IBAction private func continueWithGoogle(_ sender: Any) {
        googleSignIn.signIn(from: self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let credential):
                self.handleGoogleCredential(credential)
            case .failure(.canceled):
                break
            case .failure(let error):
                if let message = error.errorDescription, !message.isEmpty {
                    self.showAlert(message: message)
                }
            }
        }
    }

    /// Sign in with Apple, then exchange the identity token with DubaiVibe auth.
    private func handleAppleCredential(_ credential: AppleSignInService.Credential) {
        persistAppleProfile(from: credential)
        viewModel.loginWithApple(credential: credential) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.showSuccessToast(response.message, fallback: "Signed in")
                let cached = TokenManager.shared.appleUserName(for: credential.userId)
                let (first, last) = Self.splitPersonName(
                    givenName: credential.givenName,
                    familyName: credential.familyName,
                    fullName: credential.fullName ?? cached
                )
                AppRouter.continueAfterLogin(
                    from: self,
                    user: response.resolvedUser,
                    firstName: first,
                    lastName: last
                )
            case .failure(let error):
                self.showErrorPopup(error)
            }
        }
    }

    /// Native Google Sign-In, then exchange the ID token with DubaiVibe auth.
    private func handleGoogleCredential(_ credential: GoogleSignInService.Credential) {
        if let email = credential.email, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: "GoogleSignInEmail")
        }
        if let fullName = credential.fullName, !fullName.isEmpty {
            TokenManager.shared.saveSocialFullName(fullName)
        }
        viewModel.loginWithGoogle(credential: credential) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.showSuccessToast(response.message, fallback: "Signed in")
                let (first, last) = Self.splitPersonName(
                    givenName: credential.givenName,
                    familyName: credential.familyName,
                    fullName: credential.fullName
                )
                AppRouter.continueAfterLogin(
                    from: self,
                    user: response.resolvedUser,
                    firstName: first,
                    lastName: last
                )
            case .failure(let error):
                self.showErrorPopup(error)
            }
        }
    }

    private func persistAppleProfile(from credential: AppleSignInService.Credential) {
        if let email = credential.email, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: "AppleSignInEmail")
        }
        if let given = credential.givenName, !given.isEmpty {
            UserDefaults.standard.set(given, forKey: "AppleSignInGivenName")
        }
        if let family = credential.familyName, !family.isEmpty {
            UserDefaults.standard.set(family, forKey: "AppleSignInFamilyName")
        }

        let cached = TokenManager.shared.appleUserName(for: credential.userId)
        let resolvedName = credential.fullName ?? cached
        TokenManager.shared.saveAppleUserName(appleUserId: credential.userId, fullName: resolvedName)
    }

    static func splitPersonName(
        givenName: String?,
        familyName: String?,
        fullName: String?
    ) -> (String?, String?) {
        let given = givenName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let family = familyName?.trimmingCharacters(in: .whitespacesAndNewlines)
        if let given, !given.isEmpty, let family, !family.isEmpty {
            return (given, family)
        }

        let parts = (fullName ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }

        guard !parts.isEmpty else {
            return (
                given?.isEmpty == false ? given : nil,
                family?.isEmpty == false ? family : nil
            )
        }
        if parts.count == 1 {
            return (parts[0], family?.isEmpty == false ? family : nil)
        }
        return (parts[0], parts.dropFirst().joined(separator: " "))
    }
}

extension SignupOptionsVC: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        switch URL {
        case Link.terms:
            showAlert(title: L10n.termsOfService, message: L10n.termsSoon)
        case Link.privacy:
            showAlert(title: L10n.privacyPolicy, message: L10n.privacySoon)
        default:
            break
        }
        return false
    }
}
