import UIKit

@objc(ProfileViewController)
final class ProfileViewController: UIViewController {
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var bellDotView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var cameraBadge: UIView!
    @IBOutlet weak var firstNameField: AuthDarkField!
    @IBOutlet weak var lastNameField: AuthDarkField!
    @IBOutlet weak var saveButton: GoldGradientButton!

    private let languageRow = LanguageSettingRow()
    private var imagePicker: TDImagePicker?
    private var pendingAvatarImage: UIImage?
    private var baselineFirstName = ""
    private var baselineLastName = ""
    private var avatarChanged = false

    private enum Storage {
        static let firstNameKey = "profile.firstName"
        static let lastNameKey = "profile.lastName"
        static let avatarFileName = "profile_avatar.jpg"
    }

    private enum SaveStyle {
        static let enabledAlpha: CGFloat = 1
        static let disabledAlpha: CGFloat = 0.4
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background
        authDismissKeyboardOnTap()
        configureHeader()
        configureFields()
        configureLanguageRow()
        configureAvatar()
        configureSaveButton()
        loadSavedProfile()
        updateSaveButtonState()
        applyLocalizedStoryboardCopy()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        applyCircularAvatar()
        if let cameraBadge {
            cameraBadge.layer.cornerRadius = min(cameraBadge.bounds.width, cameraBadge.bounds.height) / 2
        }
    }

    /// Mirrors the brand bar on Explore so both tabs share one header treatment.
    private func configureHeader() {
        brandImageView?.image = UIImage(named: "ExploreBrandLogo") ?? UIImage(named: "dubai vibe logo") ?? UIImage(named: "LaunchLogo")
        brandImageView?.contentMode = .scaleAspectFit
        brandImageView?.layer.cornerRadius = 14
        brandImageView?.layer.cornerCurve = .continuous
        brandImageView?.clipsToBounds = true
        brandImageView?.accessibilityLabel = L10n.brandName

        taglineLabel?.attributedText = NSAttributedString(
            string: L10n.tagline,
            attributes: [
                .font: AppTypography.font(.medium, size: 9.5),
                .foregroundColor: AppPalette.tagline,
                .kern: 1.9
            ]
        )

        notificationButton?.setImage(UIImage(named: "ExploreBell"), for: .normal)
        notificationButton?.tintColor = nil
        notificationButton?.accessibilityLabel = L10n.notifications
        notificationButton?.addTarget(self, action: #selector(handleNotifications), for: .touchUpInside)

        bellDotView?.backgroundColor = AppPalette.badgeRed
        bellDotView?.layer.cornerRadius = 4.5
        bellDotView?.layer.borderWidth = 1.5
        bellDotView?.layer.borderColor = AppPalette.background.cgColor
        bellDotView?.isUserInteractionEnabled = false
    }

    @objc private func handleNotifications() {
        bellDotView?.isHidden = true
        showAlert(title: L10n.notifications, message: L10n.comingSoon)
    }

    private func configureFields() {
        firstNameField?.placeholder = L10n.firstName
        firstNameField?.textField.autocapitalizationType = .words
        firstNameField?.textField.returnKeyType = .next
        firstNameField?.textField.addTarget(self, action: #selector(firstReturn), for: .editingDidEndOnExit)
        firstNameField?.textField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)

        lastNameField?.placeholder = L10n.lastName
        lastNameField?.textField.autocapitalizationType = .words
        lastNameField?.textField.returnKeyType = .done
        lastNameField?.textField.addTarget(self, action: #selector(lastReturn), for: .editingDidEndOnExit)
        lastNameField?.textField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
    }

    private func configureLanguageRow() {
        guard let lastNameField, let saveButton, let content = lastNameField.superview else { return }

        languageRow.refresh()
        languageRow.addTarget(self, action: #selector(languageRowTapped), for: .touchUpInside)
        content.addSubview(languageRow)

        content.constraints
            .filter { constraint in
                constraint.firstItem === saveButton
                    && constraint.firstAttribute == .top
                    && constraint.secondItem === lastNameField
            }
            .forEach { $0.isActive = false }

        NSLayoutConstraint.activate([
            languageRow.leadingAnchor.constraint(equalTo: lastNameField.leadingAnchor),
            languageRow.trailingAnchor.constraint(equalTo: lastNameField.trailingAnchor),
            languageRow.topAnchor.constraint(equalTo: lastNameField.bottomAnchor, constant: 14),
            saveButton.topAnchor.constraint(equalTo: languageRow.bottomAnchor, constant: 30)
        ])
    }

    @objc private func languageRowTapped() {
        let sheet = UIAlertController(title: L10n.language, message: nil, preferredStyle: .actionSheet)
        let current = LocalizationManager.shared.language
        for language in AppLanguage.allCases {
            let title = language == current
                ? "✓ \(language.nativeName)"
                : language.nativeName
            sheet.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                self?.changeLanguage(to: language)
            })
        }
        sheet.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = languageRow
            popover.sourceRect = languageRow.bounds
        }
        presentStyledAlert(sheet)
    }

    private func changeLanguage(to language: AppLanguage) {
        guard LocalizationManager.shared.setLanguage(language) else { return }
        AppRouter.reloadInterface(selectingProfile: true)
    }

    private func configureAvatar() {
        avatarImageView?.backgroundColor = AppPalette.surface
        avatarImageView?.tintColor = AppPalette.gold
        // Keep gold tint while action sheet is presented (UIKit otherwise dims it).
        avatarImageView?.tintAdjustmentMode = .normal
        avatarImageView?.layer.borderWidth = 3
        avatarImageView?.layer.borderColor = AppPalette.gold.cgColor

        cameraBadge?.backgroundColor = AppPalette.gold
        cameraBadge?.layer.cornerRadius = 16
        cameraBadge?.clipsToBounds = true
        cameraBadge?.tintAdjustmentMode = .normal

        if let iconView = cameraBadge?.subviews.first as? UIImageView {
            let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
            iconView.image = UIImage(systemName: "camera.fill", withConfiguration: config)?
                .withRenderingMode(.alwaysTemplate)
            iconView.tintColor = AppPalette.onGold
            iconView.tintAdjustmentMode = .normal
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView?.isUserInteractionEnabled = true
        avatarImageView?.addGestureRecognizer(tap)

        let badgeTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        cameraBadge?.isUserInteractionEnabled = true
        cameraBadge?.addGestureRecognizer(badgeTap)

        imagePicker = TDImagePicker(presentationController: self, delegate: self)
    }

    private func configureSaveButton() {
        saveButton?.setTitle(L10n.save, for: .normal)
        saveButton?.setTitleColor(AppPalette.onGold, for: .normal)
        saveButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        saveButton?.clipsToBounds = true
        saveButton?.layer.cornerRadius = 14
    }

    private func loadSavedProfile() {
        let defaults = UserDefaults.standard
        let first = (defaults.string(forKey: Storage.firstNameKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (defaults.string(forKey: Storage.lastNameKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        firstNameField?.text = first
        lastNameField?.text = last
        baselineFirstName = first
        baselineLastName = last
        avatarChanged = false

        if let image = loadAvatarFromDisk() {
            pendingAvatarImage = image
            applyPhotoAvatar(image)
        } else {
           //
        }
    }

    private func applyPhotoAvatar(_ image: UIImage) {
        avatarImageView?.image = image
        avatarImageView?.tintColor = nil
        avatarImageView?.contentMode = .scaleAspectFill
    }

    @objc private func fieldsChanged() {
        updateSaveButtonState()
    }

    private var hasUnsavedChanges: Bool {
        let first = (firstNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (lastNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return first != baselineFirstName
            || last != baselineLastName
            || avatarChanged
    }

    private func updateSaveButtonState() {
        let enabled = hasUnsavedChanges
        saveButton?.isEnabled = enabled
        saveButton?.alpha = enabled ? SaveStyle.enabledAlpha : SaveStyle.disabledAlpha
    }

    @objc private func firstReturn() {
        lastNameField?.textField.becomeFirstResponder()
    }

    @objc private func lastReturn() {
        lastNameField?.textField.resignFirstResponder()
        guard hasUnsavedChanges else { return }
        saveTapped(nil)
    }

    @objc private func avatarTapped() {
        guard let avatarImageView else { return }
        imagePicker?.present(from: avatarImageView)
    }

    @IBAction private func saveTapped(_ sender: Any?) {
        guard hasUnsavedChanges else { return }
        view.endEditing(true)

        let first = (firstNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (lastNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = validationMessage(forFirstName: first, lastName: last) {
            showAlert(message: error)
            return
        }

        UserDefaults.standard.set(first, forKey: Storage.firstNameKey)
        UserDefaults.standard.set(last, forKey: Storage.lastNameKey)

        if let image = pendingAvatarImage, avatarChanged {
            saveAvatarToDisk(image)
        }

        baselineFirstName = first
        baselineLastName = last
        avatarChanged = false
        updateSaveButtonState()

        showAlert(title: L10n.saved, message: L10n.profileUpdated)
    }

    private func validationMessage(forFirstName first: String, lastName last: String) -> String? {
        if first.isEmpty {
            return L10n.enterFirstName
        }
        if first.count < 2 {
            return L10n.firstNameTooShort
        }
        if !isValidPersonName(first) {
            return L10n.invalidFirstName
        }
        if last.isEmpty {
            return L10n.enterLastName
        }
        if last.count < 2 {
            return L10n.lastNameTooShort
        }
        if !isValidPersonName(last) {
            return L10n.invalidLastName
        }
        return nil
    }

    private func isValidPersonName(_ name: String) -> Bool {
        let allowed = CharacterSet.letters
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "'-"))
        return !name.isEmpty && name.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    private var avatarFileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Storage.avatarFileName)
    }

    private func saveAvatarToDisk(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: avatarFileURL, options: .atomic)
    }

    private func loadAvatarFromDisk() -> UIImage? {
        let url = avatarFileURL
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return UIImage(data: data)
    }
}

extension ProfileViewController: TDImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image else { return }
        pendingAvatarImage = image
        avatarChanged = true
        applyPhotoAvatar(image)
        updateSaveButtonState()
    }
}
