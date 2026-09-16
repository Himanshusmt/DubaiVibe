import UIKit
import SDWebImage

@objc(ProfileViewController)
final class ProfileViewController: UIViewController {
    @IBOutlet private weak var brandImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var cameraBadge: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var contactLabel: UILabel!
    @IBOutlet private weak var vipBadgeView: ProfileVIPBadgeView!
    @IBOutlet private weak var languageRow: ProfileSettingRow!
    @IBOutlet private weak var languageValueLabel: UILabel!
    @IBOutlet private weak var pushSwitch: UISwitch!
    @IBOutlet private weak var versionLabel: UILabel!

    private var imagePicker: TDImagePicker?
    private let viewModel = ProfileViewModel()

    private enum Storage {
        static let firstNameKey = "profile.firstName"
        static let lastNameKey = "profile.lastName"
        static let avatarFileName = "profile_avatar.jpg"
        static let pushEnabledKey = "profile.pushNotificationsEnabled"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureChrome()
        configureActions()
        applyLocalizedStoryboardCopy()
        applyUser(viewModel.cachedUser)
        fetchCurrentUser()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarImageView?.makeCircular()
        cameraBadge?.applyCircularBadge()
        applyFloatingTabInset()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        languageValueLabel?.text = Self.languageValueText
        if viewModel.user == nil {
            applyUser(viewModel.cachedUser)
        }
        fetchCurrentUser(showLoader: false)
        refreshFloatingTabBarIfNeeded(animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshFloatingTabBarIfNeeded(animated: false)
    }
}

// MARK: - Chrome

private extension ProfileViewController {
    func configureChrome() {
        view.backgroundColor = AppPalette.background
        scrollView?.contentInsetAdjustmentBehavior = .never
        scrollView?.showsVerticalScrollIndicator = false

        brandImageView?.applyBrandTileChrome()
        brandImageView?.accessibilityLabel = L10n.brandName

        pushSwitch?.onTintColor = AppPalette.gold
        pushSwitch?.isOn = UserDefaults.standard.object(forKey: Storage.pushEnabledKey) as? Bool ?? true
        languageValueLabel?.text = Self.languageValueText

        imagePicker = TDImagePicker(presentationController: self, delegate: self)
    }

    func configureActions() {
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView?.isUserInteractionEnabled = true
        avatarImageView?.addGestureRecognizer(avatarTap)

        let badgeTap = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        cameraBadge?.isUserInteractionEnabled = true
        cameraBadge?.addGestureRecognizer(badgeTap)
    }

    func applyFloatingTabInset() {
        guard let scrollView else { return }
        let bottom = AppMetrics.floatingTabPillSize.height
            + AppMetrics.floatingTabBottomInset(for: view)
            + 12
        if scrollView.contentInset.bottom != bottom {
            scrollView.contentInset.bottom = bottom
            scrollView.verticalScrollIndicatorInsets.bottom = bottom
        }
    }

    func refreshFloatingTabBarIfNeeded(animated: Bool) {
        let refresh = { [weak self] in
            (self?.tabBarController as? MainTabBarController)?.refreshFloatingTabBarLayout()
        }
        if animated, let coordinator = transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in refresh() }, completion: { _ in refresh() })
        } else {
            refresh()
        }
    }

    static var languageValueText: String {
        let language = LocalizationManager.shared.language
        return "\(language.nativeName) (\(language.code.uppercased()))"
    }
}

// MARK: - User binding

private extension ProfileViewController {
    func fetchCurrentUser(showLoader: Bool = false) {
        viewModel.loadUser(showLoader: showLoader) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.applyUser(user)
                case .failure:
                    if self?.viewModel.user == nil {
                        self?.applyUser(self?.viewModel.cachedUser)
                    }
                }
            }
        }
    }

    func applyUser(_ user: AuthUser?) {
        let defaults = UserDefaults.standard
        let localFirst = (defaults.string(forKey: Storage.firstNameKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let localLast = (defaults.string(forKey: Storage.lastNameKey) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let apiName = user?.resolvedFullName
        let localName = [localFirst, localLast].filter { !$0.isEmpty }.joined(separator: " ")
        let fullName = !(apiName ?? "").isEmpty ? (apiName ?? "") : (localName.isEmpty ? "Guest" : localName)
        nameLabel?.text = fullName.split(separator: " ").first.map(String.init) ?? fullName

        let phone = user?.resolvedPhoneDisplay
        let email = user?.email
            ?? defaults.string(forKey: "AppleSignInEmail")
            ?? defaults.string(forKey: "GoogleSignInEmail")
        contactLabel?.text = Self.contactLine(phone: phone, email: email)

        if let notifications = user?.notificationsEnabled {
            pushSwitch?.isOn = notifications
            defaults.set(notifications, forKey: Storage.pushEnabledKey)
        }

        if let remote = user?.avatarURL, !remote.isEmpty {
            avatarImageView?.setBusinessImage(urlString: remote)
            avatarImageView?.contentMode = .scaleAspectFill
            avatarImageView?.tintColor = nil
        } else if let localAvatar = Self.loadAvatarFromDisk() {
            applyPhotoAvatar(localAvatar)
        } else {
            applyPlaceholderAvatar()
        }
    }

    static func contactLine(phone: String?, email: String?) -> String {
        let parts = [phone, email]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return parts.isEmpty ? L10n.profileContactPlaceholder : parts.joined(separator: "  •  ")
    }

    func applyPhotoAvatar(_ image: UIImage) {
        avatarImageView?.image = image
        avatarImageView?.tintColor = nil
        avatarImageView?.contentMode = .scaleAspectFill
    }

    func applyPlaceholderAvatar() {
        avatarImageView?.sd_cancelCurrentImageLoad()
        avatarImageView?.image = UIImage(named: "avatarIcon")
        avatarImageView?.contentMode = .scaleAspectFill
        avatarImageView?.tintColor = nil
    }

    static func loadAvatarFromDisk() -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Storage.avatarFileName)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url)
        else { return nil }
        return UIImage(data: data)
    }

    func saveAvatarToDisk(_ image: UIImage) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Storage.avatarFileName)
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: url, options: .atomic)
    }

    func removeAvatarFromDisk() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(Storage.avatarFileName)
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - Actions

extension ProfileViewController {
    @objc private func avatarTapped() {
        guard let avatarImageView else { return }
        imagePicker?.present(
            from: avatarImageView,
            showsDeleteOption: viewModel.canDeleteAvatar
        )
    }

    @IBAction private func pushSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: Storage.pushEnabledKey)
    }

    @IBAction private func editProfileTapped() {
        EditProfileViewController.open(from: self)
    }

    @IBAction private func languageTapped() {
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
            popover.sourceRect = languageRow?.bounds ?? .zero
        }
        presentStyledAlert(sheet)
    }

    @IBAction private func faqTapped() {
        showAnimatedAlert(title: L10n.profileFAQTitle, message: L10n.comingSoon, style: .info)
    }

    @IBAction private func termsTapped() {
        showAnimatedAlert(title: L10n.profileTermsTitle, message: L10n.termsSoon, style: .info)
    }

    @IBAction private func privacyTapped() {
        showAnimatedAlert(title: L10n.privacyPolicy, message: L10n.privacySoon, style: .info)
    }

    @IBAction private func logOutTapped() {
        let sheet = UIAlertController(
            title: L10n.profileLogOut,
            message: L10n.profileLogOutConfirm,
            preferredStyle: .actionSheet
        )
        sheet.addAction(UIAlertAction(title: L10n.profileLogOut, style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        sheet.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY - 120, width: 1, height: 1)
        }
        presentStyledAlert(sheet)
    }

    @IBAction private func deleteAccountTapped() {
        let alert = UIAlertController(
            title: L10n.profileDeleteTitle,
            message: L10n.profileDeleteConfirm,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.profileDeleteTitle, style: .destructive) { [weak self] _ in
            self?.performDeleteAccount()
        })
        presentStyledAlert(alert)
    }

    private func changeLanguage(to language: AppLanguage) {
        guard LocalizationManager.shared.setLanguage(language) else { return }
        AppRouter.reloadInterface(selectingProfile: true)
    }

    private func performLogout() {
        viewModel.logout { [weak self] _ in
            DispatchQueue.main.async {
                self?.navigateToSignupOptions()
            }
        }
    }

    private func performDeleteAccount() {
        viewModel.deleteAccount { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.navigateToSignupOptions()
                case .failure(let error):
                    self?.showAnimatedAlert(
                        title: L10n.error,
                        message: error.localizedDescription,
                        style: .warning
                    )
                }
            }
        }
    }

    /// Root → Authentication storyboard → `SignupOptionsVC`.
    private func navigateToSignupOptions() {
        AppRouter.setRootAuth(animated: true)
    }
}

extension ProfileViewController: TDImagePickerDelegate {
    func didSelect(image: UIImage?) {
        guard let image else { return }
        applyPhotoAvatar(image)
        saveAvatarToDisk(image)

        viewModel.uploadAndUpdateAvatar(image) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let payload):
                    if let remote = payload.upload.resolvedSourceURL {
                        self?.avatarImageView?.setBusinessImage(urlString: remote)
                        self?.avatarImageView?.contentMode = .scaleAspectFill
                        self?.avatarImageView?.tintColor = nil
                    }
                    self?.applyUser(self?.viewModel.user)
                    self?.showAnimatedAlert(
                        title: L10n.saved,
                        message: L10n.profileUpdated,
                        style: .success
                    )
                case .failure(let error):
                    self?.showAnimatedAlert(
                        title: L10n.error,
                        message: error.localizedDescription,
                        style: .warning
                    )
                }
            }
        }
    }

    func didTapDeletePhoto() {
        viewModel.deleteAvatar { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.removeAvatarFromDisk()
                    self?.applyPlaceholderAvatar()
                    self?.applyUser(self?.viewModel.user)
                    self?.showAnimatedAlert(
                        title: L10n.saved,
                        message: L10n.photoDeleted,
                        style: .success
                    )
                case .failure(let error):
                    self?.showAnimatedAlert(
                        title: L10n.error,
                        message: error.localizedDescription,
                        style: .warning
                    )
                }
            }
        }
    }
}
