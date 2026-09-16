import UIKit

@objc(EditProfileViewController)
final class EditProfileViewController: UIViewController {
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet weak var taglineLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var bellDotView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var cameraBadge: UIView!
    @IBOutlet weak var firstNameField: AuthDarkField!
    @IBOutlet weak var lastNameField: AuthDarkField!
    @IBOutlet weak var saveButton: GoldGradientButton!

    private let viewModel = ProfileViewModel()
    private var imagePicker: TDImagePicker?
    private var pendingAvatarImage: UIImage?
    private var baselineFirstName = ""
    private var baselineLastName = ""
    private var avatarChanged = false
    private var isSaving = false

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
        configureBackButton()
        configureFields()
        configureAvatar()
        configureSaveButton()
        loadSavedProfile()
        updateSaveButtonState()
        applyLocalizedStoryboardCopy()
        viewModel.loadUser(showLoader: false) { [weak self] _ in
            guard let self, !self.hasUnsavedChanges else { return }
            self.loadSavedProfile()
            self.updateSaveButtonState()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView?.makeCircular()
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
        NotificationsViewController.open(from: self)
    }
    

    private func configureBackButton() {
        guard let brandImageView, let header = brandImageView.superview else { return }

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white
        backButton.backgroundColor = AppPalette.surfaceRaised
        backButton.layer.cornerRadius = 18
        backButton.clipsToBounds = true
        backButton.accessibilityLabel = L10n.back
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        header.addSubview(backButton)

        header.constraints
            .filter { $0.firstItem === brandImageView && $0.firstAttribute == .leading }
            .forEach { $0.isActive = false }

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: header.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),
            brandImageView.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 10)
        ])
    }

    @objc private func handleBack() {
        if let nav = navigationController, nav.viewControllers.first !== self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    static func open(from presenter: UIViewController) {
        guard let controller = UIStoryboard.main.instantiateViewController(
            withIdentifier: "EditProfileViewController"
        ) as? EditProfileViewController else {
            return
        }
        controller.hidesBottomBarWhenPushed = true
        if let nav = presenter.navigationController {
            nav.pushViewController(controller, animated: true)
        } else {
            controller.modalPresentationStyle = .fullScreen
            presenter.present(controller, animated: true)
        }
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
        let user = viewModel.user ?? viewModel.cachedUser
        let storedFirst = (defaults.string(forKey: Storage.firstNameKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let storedLast = (defaults.string(forKey: Storage.lastNameKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let first = storedFirst.isEmpty ? (user?.resolvedFirstName ?? "") : storedFirst
        let last = storedLast.isEmpty ? (user?.resolvedLastName ?? "") : storedLast
        firstNameField?.text = first
        lastNameField?.text = last
        baselineFirstName = first
        baselineLastName = last
        avatarChanged = false

        if let remote = user?.resolvedAvatarURL, !remote.isEmpty {
            avatarImageView?.setBusinessImage(urlString: remote)
            avatarImageView?.contentMode = .scaleAspectFill
            avatarImageView?.tintColor = nil
        } else if let image = loadAvatarFromDisk() {
            pendingAvatarImage = image
            applyPhotoAvatar(image)
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
        let enabled = hasUnsavedChanges && !isSaving
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
        guard hasUnsavedChanges, !isSaving else { return }
        view.endEditing(true)

        let first = (firstNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let last = (lastNameField?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        if let error = validationMessage(forFirstName: first, lastName: last) {
            showNameValidationAlert(error, firstNameField: firstNameField, lastNameField: lastNameField)
            return
        }

        isSaving = true
        saveButton?.isEnabled = false
        let imageToUpload = avatarChanged ? pendingAvatarImage : nil

        viewModel.saveEditedProfile(
            firstName: first,
            lastName: last,
            avatarImage: imageToUpload
        ) { [weak self] result in
            guard let self else { return }
            self.isSaving = false
            switch result {
            case .success(let response):
                LocalUserStore.persistName(first: first, last: last)
                TokenManager.shared.saveSocialFullName("\(first) \(last)")
                if let image = imageToUpload {
                    LocalUserStore.persistAvatar(image)
                }
                self.baselineFirstName = first
                self.baselineLastName = last
                self.avatarChanged = false
                self.updateSaveButtonState()
                let apiMessage = (response.message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                self.showAnimatedAlert(
                    title: L10n.saved,
                    message: apiMessage.isEmpty ? L10n.profileUpdated : apiMessage,
                    style: .success
                )
            case .failure(let error):
                self.updateSaveButtonState()
                self.showAnimatedAlert(
                    title: L10n.error,
                    message: error.localizedDescription,
                    style: .warning
                )
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

extension EditProfileViewController: TDImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image else { return }
        pendingAvatarImage = image
        avatarChanged = true
        applyPhotoAvatar(image)
        updateSaveButtonState()
    }
}
