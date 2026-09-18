import UIKit

final class OnboardingNameVC: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var firstNameField: AuthDarkField!
    @IBOutlet private weak var lastNameField: AuthDarkField!
    @IBOutlet private weak var createButton: GoldGradientButton!
    @IBOutlet private weak var contentScrollView: UIScrollView?
    @IBOutlet private weak var termsTextView: UITextView!

    private let viewModel = AuthViewModel()
    private var isSubmitting = false
    var prefillFirstName: String?
    var prefillLastName: String?

    private enum Link {
        static let terms = URL(string: "dubaivibe://terms")!
        static let privacy = URL(string: "dubaivibe://privacy")!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        authDismissKeyboardOnTap()

        firstNameField?.placeholder = L10n.firstName
        firstNameField?.textField.autocapitalizationType = .words
        firstNameField?.textField.returnKeyType = .next
        firstNameField?.textField.addTarget(self, action: #selector(firstReturn), for: .editingDidEndOnExit)

        lastNameField?.placeholder = L10n.lastName
        lastNameField?.textField.autocapitalizationType = .words
        lastNameField?.textField.returnKeyType = .done
        lastNameField?.textField.addTarget(self, action: #selector(lastReturn), for: .editingDidEndOnExit)
        if let contentScrollView {
            pinAuthScrollViewToKeyboard(contentScrollView)
        }

        if let prefillFirstName, Self.isPersonName(prefillFirstName) {
            firstNameField?.text = prefillFirstName
        }
        if let prefillLastName, Self.isPersonName(prefillLastName) {
            lastNameField?.text = prefillLastName
        }

        createButton?.setTitleColor(AppPalette.onGold, for: .normal)
        createButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        createButton?.clipsToBounds = true
        createButton?.setTitle(L10n.createAccount, for: .normal)
        titleLabel?.text = L10n.nameTitle
        subtitleLabel?.text = L10n.nameSubtitle
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

    @IBAction private func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    @objc private func firstReturn() {
        lastNameField?.textField.becomeFirstResponder()
    }

    @objc private func lastReturn() {
        lastNameField?.textField.resignFirstResponder()
        createAccount(nil)
    }

    @IBAction private func createAccount(_ sender: Any?) {
        view.endEditing(true)
        guard !isSubmitting else { return }

        let first = (firstNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (lastNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = validationMessage(forFirstName: first, lastName: last) {
            showNameValidationAlert(error, firstNameField: firstNameField, lastNameField: lastNameField)
            return
        }
        let fullName = "\(first) \(last)".trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(first, forKey: "profile.firstName")
        UserDefaults.standard.set(last, forKey: "profile.lastName")
        TokenManager.shared.saveSocialFullName(fullName)

        isSubmitting = true
        // Request location at signup so the system permission prompt appears,
        // then send lat/lng with the complete-profile PATCH.
        LocationManager.shared.resolveCurrentLatLng { [weak self] latitude, longitude in
            guard let self else { return }
            self.viewModel.updateProfileName(
                fullName,
                latitude: latitude,
                longitude: longitude
            ) { [weak self] result in
                guard let self else { return }
                self.isSubmitting = false
                switch result {
                case .success:
                    self.navigationController?.pushViewController(
                        UIStoryboard.authentication.instantiateViewController(withIdentifier: "WelcomeSuccessVC"),
                        animated: true
                    )
                case .failure(let error):
                    self.showErrorPopup(error)
                }
            }
        }
    }

    private func validationMessage(forFirstName first: String, lastName last: String) -> String? {
        if first.isEmpty {
            return L10n.enterFirstName
        }
        if first.count < 2 {
            return L10n.firstNameTooShort
        }
        if !OnboardingNameVC.isPersonName(first) {
            return L10n.invalidFirstName
        }
        if last.isEmpty {
            return L10n.enterLastName
        }
        if last.count < 2 {
            return L10n.lastNameTooShort
        }
        if !OnboardingNameVC.isPersonName(last) {
            return L10n.invalidLastName
        }
        return nil
    }

    private static func isPersonName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return false }
        let allowed = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "'-"))
        return trimmed.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}

extension OnboardingNameVC: UITextViewDelegate {
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        switch URL {
        case Link.terms:
            showAnimatedAlert(
                title: L10n.termsOfService,
                message: L10n.termsSoon,
                style: .info
            )
        case Link.privacy:
            showAnimatedAlert(
                title: L10n.privacyPolicy,
                message: L10n.privacySoon,
                style: .info
            )
        default:
            break
        }
        return false
    }
}
