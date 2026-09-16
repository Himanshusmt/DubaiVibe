import UIKit

final class LanguageSettingRow: UIControl {
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let chevronView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        refresh()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        refresh()
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted
                ? AppPalette.surfaceRaised
                : AppPalette.surface
            if isHighlighted {
                animatePressZoomIn()
            } else {
                animatePressZoomOut()
            }
        }
    }

    func refresh() {
        titleLabel.text = L10n.language
        valueLabel.text = LocalizationManager.shared.language.nativeName
        accessibilityLabel = L10n.language
        accessibilityValue = LocalizationManager.shared.language.nativeName
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppPalette.surface
        layer.cornerRadius = AuthMetrics.corner
        layer.cornerCurve = .continuous
        layer.borderWidth = 1
        layer.borderColor = AppPalette.separator.cgColor
        isAccessibilityElement = true
        accessibilityTraits = .button

        let globe = UIImage(named: "SVG - Globe Outline Icon")
            ?? UIImage(systemName: "globe", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .medium))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = globe?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = AppPalette.gold
        iconView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .regular)
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = .systemFont(ofSize: 16, weight: .medium)
        valueLabel.textColor = AppPalette.secondaryText
        valueLabel.textAlignment = .right
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        chevronView.translatesAutoresizingMaskIntoConstraints = false
        chevronView.image = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        )
        chevronView.tintColor = AppPalette.secondaryText
        chevronView.contentMode = .scaleAspectFit

        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(chevronView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: AuthMetrics.fieldHeight),

            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 22),
            iconView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            chevronView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronView.widthAnchor.constraint(equalToConstant: 12),
            chevronView.heightAnchor.constraint(equalToConstant: 16),

            valueLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8),
            valueLabel.trailingAnchor.constraint(equalTo: chevronView.leadingAnchor, constant: -8),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
