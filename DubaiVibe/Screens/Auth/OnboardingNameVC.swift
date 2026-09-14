import UIKit

final class OnboardingNameVC: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var firstNameField: AuthDarkField!
    @IBOutlet private weak var lastNameField: AuthDarkField!
    @IBOutlet private weak var createButton: GoldGradientButton!

    private let viewModel = AuthViewModel()
    private var isSubmitting = false
    var prefillFirstName: String?
    var prefillLastName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        authDismissKeyboardOnTap()

        firstNameField?.placeholder = "First Name"
        firstNameField?.textField.autocapitalizationType = .words
        firstNameField?.textField.returnKeyType = .next
        firstNameField?.textField.addTarget(self, action: #selector(firstReturn), for: .editingDidEndOnExit)

        lastNameField?.placeholder = "Last Name"
        lastNameField?.textField.autocapitalizationType = .words
        lastNameField?.textField.returnKeyType = .done
        lastNameField?.textField.addTarget(self, action: #selector(lastReturn), for: .editingDidEndOnExit)

        firstNameField?.placeholder = "First Name"
        lastNameField?.placeholder = "Last Name"
        firstNameField?.text = ""
        lastNameField?.text = ""

        if let prefillFirstName, Self.isPersonName(prefillFirstName) {
            firstNameField?.text = prefillFirstName
        }
        if let prefillLastName, Self.isPersonName(prefillLastName) {
            lastNameField?.text = prefillLastName
        }

        createButton?.setTitleColor(AppPalette.onGold, for: .normal)
        createButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        createButton?.clipsToBounds = true
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
            showAlert(message: error)
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
                self.showSuccessToast(response.message, fallback: "Profile updated")
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
            return "Please enter your first name."
        }
        if first.count < 2 {
            return "First name must be at least 2 characters."
        }
        if !isValidPersonName(first) {
            return "Please enter a valid first name."
        }
        if last.isEmpty {
            return "Please enter your last name."
        }
        if last.count < 2 {
            return "Last name must be at least 2 characters."
        }
        if !isValidPersonName(last) {
            return "Please enter a valid last name."
        }
        return nil
    }

    /// Letters, spaces, hyphen, and apostrophe only (e.g. Mary-Jane, O'Brien).
    private func isValidPersonName(_ name: String) -> Bool {
        Self.isPersonName(name)
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
