import UIKit

final class WelcomeSuccessVC: UIViewController {
    private let logo = AuthLogoView(compact: true)
    private let checkContainer = UIView()
    private let checkImageView = UIImageView()
    private let raysView = RaysView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let continueButton = GoldGradientButton.authPrimary(title: "Start Exploring")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = AppPalette.background
        buildUI()
    }

    private func buildUI() {
        raysView.translatesAutoresizingMaskIntoConstraints = false
        raysView.isUserInteractionEnabled = false

        checkContainer.translatesAutoresizingMaskIntoConstraints = false
        checkContainer.backgroundColor = AppPalette.gold
        checkContainer.layer.cornerRadius = 56

        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold)
        checkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkImageView.image = UIImage(systemName: "checkmark", withConfiguration: config)
        checkImageView.tintColor = .white
        checkImageView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Welcome to OneVibe!"
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Your account is ready."
        subtitleLabel.textColor = AppPalette.secondaryText
        subtitleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        subtitleLabel.textAlignment = .center

        continueButton.addTarget(self, action: #selector(startExploring), for: .touchUpInside)

        view.addSubview(logo)
        view.addSubview(raysView)
        view.addSubview(checkContainer)
        checkContainer.addSubview(checkImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            checkContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            checkContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            checkContainer.widthAnchor.constraint(equalToConstant: 112),
            checkContainer.heightAnchor.constraint(equalToConstant: 112),

            raysView.centerXAnchor.constraint(equalTo: checkContainer.centerXAnchor),
            raysView.centerYAnchor.constraint(equalTo: checkContainer.centerYAnchor),
            raysView.widthAnchor.constraint(equalToConstant: 220),
            raysView.heightAnchor.constraint(equalToConstant: 220),

            checkImageView.centerXAnchor.constraint(equalTo: checkContainer.centerXAnchor),
            checkImageView.centerYAnchor.constraint(equalTo: checkContainer.centerYAnchor),
            checkImageView.widthAnchor.constraint(equalToConstant: 48),
            checkImageView.heightAnchor.constraint(equalToConstant: 48),

            titleLabel.topAnchor.constraint(equalTo: checkContainer.bottomAnchor, constant: 36),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthMetrics.gutter),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuthMetrics.gutter),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AuthMetrics.gutter),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AuthMetrics.gutter),
            continueButton.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -24
            )
        ])
    }

    @objc private func startExploring() {
        navigationController?.pushViewController(NotificationsPermissionVC(), animated: true)
    }
}

private final class RaysView: UIView {
    override class var layerClass: AnyClass { CAShapeLayer.self }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let shape = layer as? CAShapeLayer else { return }
        let path = UIBezierPath()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let inner: CGFloat = 70
        let outer: CGFloat = 100
        let count = 16
        for i in 0..<count {
            let angle = (CGFloat(i) / CGFloat(count)) * (.pi * 2)
            path.move(to: CGPoint(x: center.x + cos(angle) * inner, y: center.y + sin(angle) * inner))
            path.addLine(to: CGPoint(x: center.x + cos(angle) * outer, y: center.y + sin(angle) * outer))
        }
        shape.path = path.cgPath
        shape.strokeColor = AppPalette.gold.cgColor
        shape.lineWidth = 3
        shape.lineCap = .round
        shape.fillColor = UIColor.clear.cgColor
    }
}
