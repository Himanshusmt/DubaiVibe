import SDWebImage
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
    private var isChipSelected = false

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
        applyCapsuleRadius()
    }

    override func layoutSubviews() {
        applyCapsuleRadius()
        super.layoutSubviews()
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        applyCapsuleRadius()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.sd_cancelCurrentImageLoad()
        titleLabel.text = nil
        iconImageView.image = nil
        isChipSelected = false
    }

    func configure(with category: ExploreCategory, selected: Bool) {
        isChipSelected = selected
        titleLabel.text = category.title
        titleLabel.font = selected ? Self.selectedFont : Self.idleFont

        let hasIcon = category.hasIcon
        let padding = hasIcon ? Self.iconChipPadding : Self.textOnlyPadding
        iconLeadingConstraint.constant = padding
        titleTrailingConstraint.constant = padding

        if hasIcon {
            iconImageView.isHidden = false
            iconWidthConstraint.constant = Self.iconWidth
            titleLeadingConstraint.constant = Self.iconSpacing
            applyIcon(category: category, selected: selected)
        } else {
            iconImageView.sd_cancelCurrentImageLoad()
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
        } else {
            chipBackgroundView.backgroundColor = AppPalette.chipFill
            chipBackgroundView.layer.borderColor = AppPalette.chipBorder.cgColor
            titleLabel.textColor = AppPalette.chipText
        }

        applyCapsuleRadius()
    }

    private func applyIcon(category: ExploreCategory, selected: Bool) {
        // Prefer local assets matched by slug/name. API category icons are SVGs and
        // are not decoded by SDWebImage without an SVG coder.
        if let local = category.localIcon {
            styleIcon(local, selected: selected)
            return
        }
        if category.iconURL != nil {
            BusinessImageLoader.setImage(
                on: iconImageView,
                urlString: category.iconURL,
                placeholder: nil
            ) { [weak self] image in
                guard let self, self.isChipSelected == selected else { return }
                self.styleIcon(image, selected: selected)
            }
        } else {
            styleIcon(nil, selected: selected)
        }
    }

    private func styleIcon(_ image: UIImage?, selected: Bool) {
        guard let image else {
            iconImageView.image = nil
            return
        }
        if selected {
            iconImageView.image = image.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = AppPalette.onGold
        } else {
            iconImageView.image = image.withRenderingMode(.alwaysOriginal)
            iconImageView.tintColor = AppPalette.gold
        }
    }

    private func applyCapsuleRadius() {
        let radius = AppMetrics.chipHeight / 2
        chipBackgroundView.layer.cornerRadius = radius
        chipBackgroundView.layer.cornerCurve = .continuous
        chipBackgroundView.layer.masksToBounds = true
        selectedFill.layer.cornerRadius = radius
        selectedFill.layer.cornerCurve = .continuous
        selectedFill.layer.masksToBounds = true
    }

    static func size(for category: ExploreCategory) -> CGSize {
        let font = category.hasIcon ? idleFont : selectedFont
        let textWidth = (category.title as NSString).size(withAttributes: [.font: font]).width
        let padding = category.hasIcon ? iconChipPadding : textOnlyPadding
        var width = ceil(textWidth) + padding * 2
        if category.hasIcon {
            width += iconWidth + iconSpacing
        }
        return CGSize(width: width, height: AppMetrics.chipHeight)
    }
}
