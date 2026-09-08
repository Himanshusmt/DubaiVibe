import UIKit

final class CategoryChipCell: UICollectionViewCell {
    static let reuseIdentifier = "CategoryChipCell"

    private static let font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    private static let horizontalPadding: CGFloat = 14
    private static let iconWidth: CGFloat = 15
    private static let iconSpacing: CGFloat = 6

    @IBOutlet private weak var chipBackgroundView: UIView!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var iconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLeadingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = AppPalette.background
        contentView.backgroundColor = AppPalette.background
        chipBackgroundView.layer.cornerRadius = AppMetrics.chipHeight / 2
        chipBackgroundView.layer.cornerCurve = .continuous
        chipBackgroundView.layer.borderWidth = 1
        chipBackgroundView.clipsToBounds = true
        titleLabel.font = Self.font
        titleLabel.textAlignment = .center
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        iconImageView.image = nil
    }

    func configure(with category: VenueCategory, selected: Bool) {
        titleLabel.text = category.title

        if let icon = category.icon {
            iconImageView.image = icon
            iconImageView.isHidden = false
            iconWidthConstraint.constant = Self.iconWidth
            titleLeadingConstraint.constant = Self.iconSpacing
        } else {
            iconImageView.image = nil
            iconImageView.isHidden = true
            iconWidthConstraint.constant = 0
            titleLeadingConstraint.constant = 0
        }

        if selected {
            chipBackgroundView.backgroundColor = AppPalette.gold
            chipBackgroundView.layer.borderColor = UIColor.clear.cgColor
            titleLabel.textColor = AppPalette.onGold
            iconImageView.tintColor = AppPalette.onGold
        } else {
            chipBackgroundView.backgroundColor = AppPalette.chipFill
            chipBackgroundView.layer.borderColor = AppPalette.chipBorder.cgColor
            titleLabel.textColor = AppPalette.primaryText
            iconImageView.tintColor = AppPalette.gold
        }
    }

    static func size(for category: VenueCategory) -> CGSize {
        let textWidth = (category.title as NSString).size(withAttributes: [.font: font]).width
        var width = ceil(textWidth) + horizontalPadding * 2
        if category.icon != nil {
            width += iconWidth + iconSpacing
        }
        return CGSize(width: width, height: AppMetrics.chipHeight)
    }
}
