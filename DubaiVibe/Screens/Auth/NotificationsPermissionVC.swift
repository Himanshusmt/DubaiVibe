import UIKit

final class NotificationsPermissionVC: UIViewController {
    private let logo = AuthLogoView(compact: true)
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let bellContainer = UIView()
    private let bellImageView = UIImageView()
    private let badgeLabel = UILabel()
    private let enableButton = GoldGradientButton.authPrimary(title: "Enable Notifications")
    private let laterButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = AppPalette.background
        buildUI()
    }

    private func buildUI() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Turn on Notifications?"
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Get updates, messages and exclusive deals from OneVibe."
        subtitleLabel.textColor = AppPalette.secondaryText
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        bellContainer.translatesAutoresizingMaskIntoConstraints = false

        let config = UIImage.SymbolConfiguration(pointSize: 72, weight: .medium)
        bellImageView.translatesAutoresizingMaskIntoConstraints = false
        bellImageView.image = UIImage(systemName: "bell.fill", withConfiguration: config)
        bellImageView.tintColor = AppPalette.gold
        bellImageView.contentMode = .scaleAspectFit

        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.text = "1"
        badgeLabel.textColor = .white
        badgeLabel.font = .systemFont(ofSize: 14, weight: .bold)
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = AppPalette.badgeRed
        badgeLabel.layer.cornerRadius = 12
        badgeLabel.clipsToBounds = true

        laterButton.translatesAutoresizingMaskIntoConstraints = false
        laterButton.setTitle("Maybe Later", for: .normal)
        laterButton.setTitleColor(AppPalette.primaryText, for: .normal)
        laterButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        enableButton.addTarget(self, action: #selector(enableTapped), for: .touchUpInside)
        laterButton.addTarget(self, action: #selector(laterTapped), for: .touchUpInside)

        view.addSubview(logo)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(bellContainer)
        bellContainer.addSubview(bellImageView)
        bellContainer.addSubview(badgeLabel)
        view.addSubview(enableButton)
        view.addSubview(laterButton)

        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            titleLabel.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 36),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthMetrics.gutter),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuthMetrics.gutter),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            bellContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bellContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10),
            bellContainer.widthAnchor.constraint(equalToConstant: 120),
            bellContainer.heightAnchor.constraint(equalToConstant: 120),

            bellImageView.centerXAnchor.constraint(equalTo: bellContainer.centerXAnchor),
            bellImageView.centerYAnchor.constraint(equalTo: bellContainer.centerYAnchor),
            bellImageView.widthAnchor.constraint(equalToConstant: 88),
            bellImageView.heightAnchor.constraint(equalToConstant: 88),

            badgeLabel.topAnchor.constraint(equalTo: bellImageView.topAnchor, constant: 4),
            badgeLabel.trailingAnchor.constraint(equalTo: bellImageView.trailingAnchor, constant: 8),
            badgeLabel.widthAnchor.constraint(equalToConstant: 24),
            badgeLabel.heightAnchor.constraint(equalToConstant: 24),

            laterButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -16
            ),
            laterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthMetrics.gutter),
            laterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuthMetrics.gutter),
            laterButton.heightAnchor.constraint(equalToConstant: 44),

            enableButton.bottomAnchor.constraint(equalTo: laterButton.topAnchor, constant: -8),
            enableButton.leadingAnchor.constraint(equalTo: laterButton.leadingAnchor),
            enableButton.trailingAnchor.constraint(equalTo: laterButton.trailingAnchor)
        ])
    }

    @objc private func enableTapped() {
        FCMNotificationManager.requestAuthorizationIfNeeded { [weak self] _ in
            self?.finishOnboarding()
        }
    }

    @objc private func laterTapped() {
        finishOnboarding()
    }

    private func finishOnboarding() {
        AppRouter.markMockSessionComplete()
        AppRouter.setRootMain(animated: true)
    }
}
