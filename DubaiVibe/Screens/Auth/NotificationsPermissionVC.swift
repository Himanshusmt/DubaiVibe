import UIKit

final class NotificationsPermissionVC: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var enableButton: GoldGradientButton!
    @IBOutlet private weak var skipButton: UIButton!

    private let viewModel = AuthViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        enableButton?.setTitleColor(AppPalette.onGold, for: .normal)
        enableButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        enableButton?.clipsToBounds = true
        enableButton?.layer.cornerRadius = 14
        titleLabel?.text = L10n.notificationsTitle
        subtitleLabel?.text = L10n.notificationSubtitle
        enableButton?.setTitle(L10n.enableNotifications, for: .normal)
        skipButton?.setTitle(L10n.skip, for: .normal)
        applyLocalizedStoryboardCopy()
    }

    @IBAction private func enableTapped(_ sender: Any) {
        setControlsEnabled(false)
        FCMNotificationManager.requestAuthorizationIfNeeded { [weak self] _ in
            self?.updateProfileAndFinishOnboarding(notificationsEnabled: true)
        }
    }

    @IBAction private func skipTapped(_ sender: Any) {
        setControlsEnabled(false)
        updateProfileAndFinishOnboarding(notificationsEnabled: false)
    }

    private func setControlsEnabled(_ enabled: Bool) {
        enableButton?.isEnabled = enabled
        skipButton?.isEnabled = enabled
    }

    private func updateProfileAndFinishOnboarding(notificationsEnabled: Bool) {
        let coordinate = LocationManager.shared.lastKnownLatLng
        viewModel.updateProfile(
            notificationsEnabled: notificationsEnabled,
            latitude: coordinate?.latitude,
            longitude: coordinate?.longitude
        ) { [weak self] result in
            guard let self else { return }
            self.setControlsEnabled(true)
            switch result {
            case .success(let response):
                AppRouter.completeOnboarding()
                if notificationsEnabled {
                    self.showSuccessToast(response.message, fallback: "Profile updated")
                }
                AppRouter.setRootMain(animated: true)
            case .failure(let error):
                TokenManager.shared.isOnboardingCompleted = false
                self.showErrorPopup(error)
            }
        }
    }
}
