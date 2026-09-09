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
        let first = (firstNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (lastNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !first.isEmpty, !last.isEmpty else {
            showAlert(message: "Please enter your first and last name.")
            return
        }
        navigationController?.pushViewController(WelcomeSuccessVC(), animated: true)
    }
}
