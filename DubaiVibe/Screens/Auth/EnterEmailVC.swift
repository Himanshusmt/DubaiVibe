import UIKit

final class EnterEmailVC: UIViewController {
    private let topBar = AuthTopBar()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let firstNameField = AuthDarkField()
    private let lastNameField = AuthDarkField()
    private let createButton = GoldGradientButton.authPrimary(title: "Create Account")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = AppPalette.background
        authDismissKeyboardOnTap()
        buildUI()
    }

    private func buildUI() {
        topBar.showsHelp = false
        topBar.showsLogo = true
        topBar.backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createAccount), for: .touchUpInside)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "What's your full name?"
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.numberOfLines = 0

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "This will be shown on your profile."
        subtitleLabel.textColor = AppPalette.secondaryText
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.numberOfLines = 0

        firstNameField.placeholder = "First Name"
        firstNameField.textField.autocapitalizationType = .words
        firstNameField.textField.returnKeyType = .next
        firstNameField.textField.addTarget(self, action: #selector(firstReturn), for: .editingDidEndOnExit)

        lastNameField.placeholder = "Last Name"
        lastNameField.textField.autocapitalizationType = .words
        lastNameField.textField.returnKeyType = .done
        lastNameField.textField.addTarget(self, action: #selector(lastReturn), for: .editingDidEndOnExit)

        view.addSubview(topBar)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(firstNameField)
        view.addSubview(lastNameField)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthMetrics.gutter),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuthMetrics.gutter),

            titleLabel.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthMetrics.gutter),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuthMetrics.gutter),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            firstNameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            firstNameField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            firstNameField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            lastNameField.topAnchor.constraint(equalTo: firstNameField.bottomAnchor, constant: 12),
            lastNameField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            lastNameField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            createButton.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 24),
            createButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            createButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func firstReturn() {
        lastNameField.textField.becomeFirstResponder()
    }

    @objc private func lastReturn() {
        lastNameField.textField.resignFirstResponder()
        createAccount()
    }

    @objc private func createAccount() {
        let first = (firstNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (lastNameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !first.isEmpty, !last.isEmpty else {
            showAlert(message: "Please enter your first and last name.")
            return
        }
        navigationController?.pushViewController(WelcomeSuccessVC(), animated: true)
    }
}
