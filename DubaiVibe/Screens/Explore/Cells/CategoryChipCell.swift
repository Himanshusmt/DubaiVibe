import UIKit

final class CategoryChipCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryChipCell"

    private static let selectedFont = AppTypography.font(.bold, size: 12)
    private static let idleFont = AppTypography.font(.medium, size: 12)
    /// Figma: All uses 16pt; icon chips use 15pt.
    private static let textOnlyPadding: CGFloat = 16
    private static let iconChipPadding: CGFloat = 15
    private static let iconWidth: CGFloat = 16
    private static let iconSpacing: CGFloat = 6

    @IBOutlet private weak var chipBackgroundView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var iconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleTrailingConstraint: NSLayoutConstraint!

    private let selectedFill = GoldGradientView()

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppPalette.background
        contentView.backgroundColor = AppPalette.background
        chipBackgroundView.layer.cornerRadius = AppMetrics.chipHeight / 2
        chipBackgroundView.layer.cornerCurve = .continuous
        chipBackgroundView.layer.borderWidth = 1
        chipBackgroundView.clipsToBounds = true
        titleLabel.font = Self.idleFont
        titleLabel.textAlignment = .center
        iconImageView.contentMode = .scaleAspectFit

        selectedFill.kind = .cta
        selectedFill.clipsToBounds = true
        selectedFill.isHidden = true
        chipBackgroundView.insertSubview(selectedFill, at: 0)
        selectedFill.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedFill.topAnchor.constraint(equalTo: chipBackgroundView.topAnchor),
            selectedFill.leadingAnchor.constraint(equalTo: chipBackgroundView.leadingAnchor),
            selectedFill.trailingAnchor.constraint(equalTo: chipBackgroundView.trailingAnchor),
            selectedFill.bottomAnchor.constraint(equalTo: chipBackgroundView.bottomAnchor)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let radius = chipBackgroundView.bounds.height / 2
        chipBackgroundView.layer.cornerRadius = radius
        selectedFill.layer.cornerRadius = radius
        selectedFill.layer.cornerCurve = .continuous
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.image = nil
    }

    func configure(with category: VenueCategory, selected: Bool) {
        titleLabel.text = category.title
        titleLabel.font = selected ? Self.selectedFont : Self.idleFont

        let hasIcon = category.icon != nil
        let padding = hasIcon ? Self.iconChipPadding : Self.textOnlyPadding
        iconLeadingConstraint.constant = padding
        titleTrailingConstraint.constant = padding

        if let icon = category.icon {
            iconImageView.isHidden = false
            iconWidthConstraint.constant = Self.iconWidth
            titleLeadingConstraint.constant = Self.iconSpacing
            // Screenshot / Figma icons are solid gold assets.
            iconImageView.image = icon.withRenderingMode(.alwaysOriginal)
            iconImageView.tintColor = AppPalette.gold
        } else {
            iconImageView.image = nil
            iconImageView.isHidden = true
            iconWidthConstraint.constant = 0
            titleLeadingConstraint.constant = 0
        }

        selectedFill.isHidden = !selected
        if selected {
            chipBackgroundView.backgroundColor = .clear
            chipBackgroundView.layer.borderColor = UIColor.clear.cgColor
            titleLabel.textColor = AppPalette.onGold
            if hasIcon {
                iconImageView.image = category.icon?.withRenderingMode(.alwaysTemplate)
                iconImageView.tintColor = AppPalette.onGold
            }
        } else {
            chipBackgroundView.backgroundColor = AppPalette.chipFill
            chipBackgroundView.layer.borderColor = AppPalette.chipBorder.cgColor
            titleLabel.textColor = AppPalette.chipText
        }
    }

    static func size(for category: VenueCategory) -> CGSize {
        let font = category.icon == nil ? selectedFont : idleFont
        let textWidth = (category.title as NSString).size(withAttributes: [.font: font]).width
        let padding = category.icon == nil ? textOnlyPadding : iconChipPadding
        var width = ceil(textWidth) + padding * 2
        if category.icon != nil {
            width += iconWidth + iconSpacing
        }
        return CGSize(width: width, height: AppMetrics.chipHeight)
    }
}
