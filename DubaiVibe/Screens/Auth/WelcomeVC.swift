import Combine
import UIKit

/// Welcome / auth entry screen. Layout and button chrome live in Authentication.storyboard.
final class WelcomeVC: UIViewController {
    @IBOutlet private weak var phoneButton: GoldGradientButton!
    @IBOutlet private weak var termsTextView: UITextView!

    private let appleSignIn = AppleSignInService()
    private let googleSignIn = GoogleSignInService()
    private var cancellables = Set<AnyCancellable>()
    private var isSocialSignInInFlight = false

    private enum Link {
        static let terms = URL(string: "dubaivibe://terms")!
        static let privacy = URL(string: "dubaivibe://privacy")!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        phoneButton?.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        configureTermsLinks()
    }

    /// Attributed links can't be authored fully in IB — only this bit stays in code.
    private func configureTermsLinks() {
        guard let termsTextView else { return }

        let font = UIFont.systemFont(ofSize: 14, weight: .regular)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let text = NSMutableAttributedString(
            string: "By continuing, you agree to our\n",
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
        let phone = UIStoryboard.authentication
            .instantiateViewController(withIdentifier: "SignUpViewController")
        navigationController?.pushViewController(phone, animated: true)
    }

    @IBAction private func continueWithApple(_ sender: Any) {
        guard !isSocialSignInInFlight else { return }
        isSocialSignInInFlight = true

        appleSignIn.signIn(from: self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let credential):
                self.handleAppleCredential(credential)
            case .failure(.canceled):
                self.isSocialSignInInFlight = false
            case .failure(let error):
                self.isSocialSignInInFlight = false
                self.showSocialSignInError(error.errorDescription)
            }
        }
    }

    @IBAction private func continueWithGoogle(_ sender: Any) {
        guard !isSocialSignInInFlight else { return }
        isSocialSignInInFlight = true

        googleSignIn.signIn(from: self) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let credential):
                self.handleGoogleCredential(credential)
            case .failure(.canceled):
                self.isSocialSignInInFlight = false
            case .failure(let error):
                self.isSocialSignInInFlight = false
                self.showSocialSignInError(error.errorDescription)
            }
        }
    }

    private func handleAppleCredential(_ credential: AppleSignInService.Credential) {
        persistAppleProfile(from: credential)
        let cached = TokenManager.shared.appleUserName(for: credential.userId)
        let (first, last) = Self.splitPersonName(
            givenName: credential.givenName,
            familyName: credential.familyName,
            fullName: credential.fullName ?? cached
        )

        AppleAuthAPI.login(credential: credential, showLoader: true)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isSocialSignInInFlight = false
                if case .failure = completion {
                    // Native Apple auth succeeded — continue onboarding if /apple is not ready yet.
                    self.routeToNameEntry(firstName: first, lastName: last)
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                self.applySocialSession(
                    accessToken: response.resolvedAccessToken,
                    onboardingCompleted: response.resolvedOnboardingCompleted
                )
                self.routeAfterSocialLogin(firstName: first, lastName: last)
            }
            .store(in: &cancellables)
    }

    private func handleGoogleCredential(_ credential: GoogleSignInService.Credential) {
        persistGoogleProfile(from: credential)
        let (first, last) = Self.splitPersonName(
            givenName: credential.givenName,
            familyName: credential.familyName,
            fullName: credential.fullName
        )

        GoogleAuthAPI.login(credential: credential, showLoader: true)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isSocialSignInInFlight = false
                if case .failure = completion {
                    // Native Google auth succeeded — continue onboarding if /google is not ready yet.
                    self.routeToNameEntry(firstName: first, lastName: last)
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                self.applySocialSession(
                    accessToken: response.resolvedAccessToken,
                    onboardingCompleted: response.resolvedOnboardingCompleted
                )
                self.routeAfterSocialLogin(firstName: first, lastName: last)
            }
            .store(in: &cancellables)
    }

    private func applySocialSession(accessToken: String?, onboardingCompleted: Bool) {
        if let token = accessToken, !token.isEmpty {
            TokenManager.shared.saveAccessToken(token)
            UserDefaults.standard.setLoggedIn(value: true)
        }
        TokenManager.shared.isOnboardingCompleted = onboardingCompleted
    }

    private func routeAfterSocialLogin(firstName: String?, lastName: String?) {
        if TokenManager.shared.isLoggedIn, TokenManager.shared.isOnboardingCompleted {
            AppRouter.setRootMain(animated: true)
        } else {
            routeToNameEntry(firstName: firstName, lastName: lastName)
        }
    }

    private func showSocialSignInError(_ message: String?) {
        guard let message, !message.isEmpty else { return }
        showAnimatedAlert(
            title: "Something went wrong",
            message: message,
            style: .warning
        )
    }

    private func persistAppleProfile(from credential: AppleSignInService.Credential) {
        UserDefaults.standard.set(credential.userId, forKey: "AppleSignInUserId")
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

    private func persistGoogleProfile(from credential: GoogleSignInService.Credential) {
        UserDefaults.standard.set(credential.userId, forKey: "GoogleSignInUserId")
        if let email = credential.email, !email.isEmpty {
            UserDefaults.standard.set(email, forKey: "GoogleSignInEmail")
        }
        if let given = credential.givenName, !given.isEmpty {
            UserDefaults.standard.set(given, forKey: "GoogleSignInGivenName")
        }
        if let family = credential.familyName, !family.isEmpty {
            UserDefaults.standard.set(family, forKey: "GoogleSignInFamilyName")
        }
        TokenManager.shared.saveSocialFullName(credential.fullName)
    }

    private func routeToNameEntry(firstName: String?, lastName: String?) {
        guard let enterEmail = UIStoryboard.authentication
            .instantiateViewController(withIdentifier: "EnterEmailVC") as? EnterEmailVC
        else { return }

        enterEmail.prefillFirstName = firstName
        enterEmail.prefillLastName = lastName
        navigationController?.pushViewController(enterEmail, animated: true)
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

extension WelcomeVC: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        switch URL {
        case Link.terms:
            showAnimatedAlert(
                title: "Terms of Service",
                message: "Terms of Service will be available soon.",
                style: .info
            )
        case Link.privacy:
            showAnimatedAlert(
                title: "Privacy Policy",
                message: "Privacy Policy will be available soon.",
                style: .info
            )
        default:
            break
        }
        return false
    }
}
