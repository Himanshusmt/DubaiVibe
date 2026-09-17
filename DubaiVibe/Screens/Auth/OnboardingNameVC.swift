import UIKit

final class OnboardingNameVC: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var firstNameField: AuthDarkField!
    @IBOutlet private weak var lastNameField: AuthDarkField!
    @IBOutlet private weak var createButton: GoldGradientButton!
    @IBOutlet private weak var contentScrollView: UIScrollView?

    private let viewModel = AuthViewModel()
    private var isSubmitting = false
    var prefillFirstName: String?
    var prefillLastName: String?

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
        viewModel.updateProfileName(fullName) { [weak self] result in
            guard let self else { return }
            self.isSubmitting = false
            switch result {
            case .success(let response):
//                self.showSuccessToast(response.message, fallback: "Profile updated")
                self.navigationController?.pushViewController(
                    UIStoryboard.authentication.instantiateViewController(withIdentifier: "WelcomeSuccessVC"),
                    animated: true
                )
            case .failure(let error):
                self.showErrorPopup(error)
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
