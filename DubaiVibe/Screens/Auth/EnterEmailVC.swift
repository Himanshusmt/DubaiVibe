import UIKit

final class EnterEmailVC: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var firstNameField: AuthDarkField!
    @IBOutlet private weak var lastNameField: AuthDarkField!
    @IBOutlet private weak var createButton: GoldGradientButton!

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

        let first = (firstNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (lastNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = validationMessage(forFirstName: first, lastName: last) {
            showAlert(message: error)
            return
        }

        navigationController?.pushViewController(
            UIStoryboard.authentication.instantiateViewController(withIdentifier: "WelcomeSuccessVC"),
            animated: true
        )
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
        let allowed = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "'-"))
        return !name.isEmpty && name.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}
