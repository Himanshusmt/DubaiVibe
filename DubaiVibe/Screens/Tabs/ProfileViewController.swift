import UIKit

@objc(ProfileViewController)
final class ProfileViewController: UIViewController {
    @IBOutlet weak var avatarImageView: CircularImageView!
    @IBOutlet weak var cameraBadge: UIView!
    @IBOutlet weak var firstNameField: AuthDarkField!
    @IBOutlet weak var lastNameField: AuthDarkField!
    @IBOutlet weak var saveButton: GoldGradientButton!

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
        configureFields()
        configureAvatar()
        configureSaveButton()
        loadSavedProfile()
        updateSaveButtonState()
    }

    private func configureFields() {
        firstNameField?.placeholder = "First Name"
        firstNameField?.textField.autocapitalizationType = .words
        firstNameField?.textField.returnKeyType = .next
        firstNameField?.textField.addTarget(self, action: #selector(firstReturn), for: .editingDidEndOnExit)
        firstNameField?.textField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)

        lastNameField?.placeholder = "Last Name"
        lastNameField?.textField.autocapitalizationType = .words
        lastNameField?.textField.returnKeyType = .done
        lastNameField?.textField.addTarget(self, action: #selector(lastReturn), for: .editingDidEndOnExit)
        lastNameField?.textField.addTarget(self, action: #selector(fieldsChanged), for: .editingChanged)
    }

    private func configureAvatar() {
        avatarImageView?.backgroundColor = AppPalette.surface
        avatarImageView?.tintColor = AppPalette.gold
        // Keep gold tint while action sheet is presented (UIKit otherwise dims it).
        avatarImageView?.tintAdjustmentMode = .normal
        avatarImageView?.layer.borderWidth = 3
        avatarImageView?.layer.borderColor = AppPalette.gold.cgColor
        avatarImageView?.layer.cornerCurve = .circular
        avatarImageView?.clipsToBounds = true
        applyPlaceholderAvatar()

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
        saveButton?.setTitle("Save", for: .normal)
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
        }
    }

    private func applyPlaceholderAvatar() {
        // Keep icon inset so the circle rim stays round (aspectFill was clipping top/bottom).
        let config = UIImage.SymbolConfiguration(pointSize: 36, weight: .regular)
        avatarImageView?.image = UIImage(systemName: "person.fill", withConfiguration: config)?
            .withRenderingMode(.alwaysTemplate)
        avatarImageView?.tintColor = AppPalette.gold
        avatarImageView?.contentMode = .center
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

        showAlert(title: "Saved", message: "Your profile has been updated.")
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
