import UIKit

final class NotificationsPermissionVC: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var enableButton: GoldGradientButton!

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
        applyLocalizedStoryboardCopy()
    }

    @IBAction private func enableTapped(_ sender: Any) {
        enableButton?.isEnabled = false
        FCMNotificationManager.requestAuthorizationIfNeeded { [weak self] _ in
            self?.updateProfileAndFinishOnboarding()
        }
    }

    private func updateProfileAndFinishOnboarding() {
        viewModel.updateProfile(notificationsEnabled: true) { [weak self] result in
            guard let self else { return }
            self.enableButton?.isEnabled = true
            switch result {
            case .success(let response):
                AppRouter.completeOnboarding()
                self.showSuccessToast(response.message, fallback: "Profile updated")
                AppRouter.setRootMain(animated: true)
            case .failure(let error):
                TokenManager.shared.isOnboardingCompleted = false
                self.showErrorPopup(error)
            }
        }
    }
}
