import UIKit

final class WelcomeSuccessVC: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var continueButton: GoldGradientButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        continueButton?.setTitleColor(AppPalette.onGold, for: .normal)
        continueButton?.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        continueButton?.clipsToBounds = true
        continueButton?.layer.cornerRadius = 14
    }

    @IBAction private func startExploring(_ sender: Any) {
        navigationController?.pushViewController(
            UIStoryboard.authentication.instantiateViewController(withIdentifier: "NotificationsPermissionVC"),
            animated: true
        )
    }
}
