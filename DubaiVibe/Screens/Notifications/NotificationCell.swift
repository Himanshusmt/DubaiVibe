import UIKit

final class NotificationCell: UITableViewCell {
    static let reuseID = "NotificationCell"

    private let card = NotificationCardView()
    private let titleLabel = UILabel()
    private let badgeLabel = UILabel()
    private let unreadDot = UIView()
    private let bodyLabel = UILabel()
    private let metaLabel = UILabel()
    private let ctaButton = UIButton(type: .system)
    private let titleRow = UIStackView()
    private let footerRow = UIStackView()
    private let contentStack = UIStackView()

    var onCTA: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func configure(_ item: AppNotification) {
        card.isFeatured = item.featured && item.isUnread
        titleLabel.text = item.displayTitle
        bodyLabel.text = item.displayBody
        bodyLabel.isHidden = item.displayBody.isEmpty
        metaLabel.text = item.metaLine
        metaLabel.isHidden = item.metaLine.isEmpty
        unreadDot.isHidden = !item.isUnread

        let badge = item.badge?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        badgeLabel.isHidden = badge.isEmpty
        if !badge.isEmpty {
            badgeLabel.text = "  \(badge)  "
        }

        let cta = item.ctaTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        ctaButton.isHidden = cta.isEmpty
        ctaButton.setTitle(cta, for: .normal)
        if item.featured && item.isUnread {
            ctaButton.backgroundColor = AppPalette.gold
            ctaButton.setTitleColor(AppPalette.onGold, for: .normal)
            ctaButton.titleLabel?.font = AppTypography.font(.bold, size: 13)
            ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
            ctaButton.layer.cornerRadius = 10
        } else {
            ctaButton.backgroundColor = .clear
            ctaButton.setTitleColor(AppPalette.gold, for: .normal)
            ctaButton.titleLabel?.font = AppTypography.font(.semibold, size: 13)
            ctaButton.contentEdgeInsets = .zero
            ctaButton.layer.cornerRadius = 0
        }
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        card.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(card)

        titleLabel.font = AppTypography.font(.semibold, size: 16)
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.numberOfLines = 2
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        badgeLabel.font = AppTypography.font(.bold, size: 11)
        badgeLabel.textColor = AppPalette.gold
        badgeLabel.backgroundColor = AppPalette.gold.withAlphaComponent(0.22)
        badgeLabel.layer.cornerRadius = 6
        badgeLabel.clipsToBounds = true
        badgeLabel.setContentHuggingPriority(.required, for: .horizontal)

        unreadDot.backgroundColor = AppPalette.gold
        unreadDot.layer.cornerRadius = 4
        unreadDot.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            unreadDot.widthAnchor.constraint(equalToConstant: 8),
            unreadDot.heightAnchor.constraint(equalToConstant: 8)
        ])

        bodyLabel.font = AppTypography.font(.regular, size: 14)
        bodyLabel.textColor = AppPalette.secondaryText
        bodyLabel.numberOfLines = 0

        metaLabel.font = AppTypography.font(.regular, size: 12)
        metaLabel.textColor = AppPalette.secondaryText
        metaLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        ctaButton.addTarget(self, action: #selector(handleCTA), for: .touchUpInside)
        ctaButton.setContentHuggingPriority(.required, for: .horizontal)

        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8
        titleRow.addArrangedSubview(titleLabel)
        titleRow.addArrangedSubview(badgeLabel)
        let titleSpacer = UIView()
        titleSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleRow.addArrangedSubview(titleSpacer)
        titleRow.addArrangedSubview(unreadDot)

        footerRow.axis = .horizontal
        footerRow.alignment = .center
        footerRow.spacing = 8
        footerRow.addArrangedSubview(metaLabel)
        let footerSpacer = UIView()
        footerSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        footerRow.addArrangedSubview(footerSpacer)
        footerRow.addArrangedSubview(ctaButton)

        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(titleRow)
        contentStack.addArrangedSubview(bodyLabel)
        contentStack.addArrangedSubview(footerRow)
        card.addSubview(contentStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            card.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),

            contentStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            contentStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            contentStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            contentStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    @objc private func handleCTA() {
        onCTA?()
    }
}
