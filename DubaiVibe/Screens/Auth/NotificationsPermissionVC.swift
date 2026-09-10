import UIKit

final class NotificationsPermissionVC: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var enableButton: GoldGradientButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        enableButton?.setTitleColor(AppPalette.onGold, for: .normal)
        enableButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        enableButton?.clipsToBounds = true
        enableButton?.layer.cornerRadius = 14
    }

    @IBAction private func enableTapped(_ sender: Any) {
        FCMNotificationManager.requestAuthorizationIfNeeded { [weak self] _ in
            self?.finishOnboarding()
        }
    }

    private func finishOnboarding() {
        AppRouter.markMockSessionComplete()
        AppRouter.setRootMain(animated: true)
    }
}
