import UIKit

final class VenueCardCell: UITableViewCell {
    static let reuseIdentifier = "VenueCardCell"

    @IBOutlet private weak var cardView: UIView!
    @IBOutlet private weak var heroImageView: UIImageView!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var wordmarkLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var verifiedImageView: UIImageView!
    @IBOutlet private weak var bookmarkButton: UIButton!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var dealBannerView: UIView!
    @IBOutlet private weak var crownBackgroundView: UIView!
    @IBOutlet private weak var crownImageView: UIImageView!
    @IBOutlet private weak var dealTitleLabel: UILabel!
    @IBOutlet private weak var dealDiscountLabel: UILabel!
    @IBOutlet private weak var dealDetailLabel: UILabel!
    @IBOutlet private weak var dealValidityLabel: UILabel!
    @IBOutlet private weak var viewDealButton: UIButton!
    @IBOutlet private weak var dealHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dealTopConstraint: NSLayoutConstraint!

    var onFavorite: (() -> Void)?
    var onBookmark: (() -> Void)?
    var onViewDeal: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = AppPalette.background
        contentView.backgroundColor = AppPalette.background
        isOpaque = true
        contentView.isOpaque = true

        cardView.backgroundColor = AppPalette.surface
        cardView.layer.cornerRadius = AppMetrics.cardRadius
        cardView.layer.cornerCurve = .continuous
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = AppPalette.cardBorder.cgColor
        cardView.clipsToBounds = true

        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.isOpaque = true

        wordmarkLabel.textColor = .white
        wordmarkLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        wordmarkLabel.adjustsFontSizeToFitWidth = true
        wordmarkLabel.minimumScaleFactor = 0.45
        wordmarkLabel.textAlignment = .center
        wordmarkLabel.layer.shadowColor = UIColor.black.cgColor
        wordmarkLabel.layer.shadowOpacity = 0.4
        wordmarkLabel.layer.shadowRadius = 8
        wordmarkLabel.layer.shadowOffset = .zero

        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = AppPalette.primaryText
        subtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subtitleLabel.textColor = AppPalette.secondaryText
        ratingLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)

        verifiedImageView.image = UIImage(systemName: "checkmark.seal.fill")
        verifiedImageView.tintColor = AppPalette.verified
        verifiedImageView.contentMode = .scaleAspectFit

        dealBannerView.backgroundColor = AppPalette.dealFill
        dealBannerView.layer.cornerRadius = 14
        dealBannerView.layer.cornerCurve = .continuous
        dealBannerView.layer.borderWidth = 1
        dealBannerView.layer.borderColor = AppPalette.dealBorder.cgColor
        dealBannerView.clipsToBounds = true

        crownBackgroundView.backgroundColor = AppPalette.crownFill
        crownBackgroundView.layer.cornerRadius = 10
        crownBackgroundView.layer.cornerCurve = .continuous
        crownBackgroundView.layer.borderWidth = 1
        crownBackgroundView.layer.borderColor = AppPalette.dealBorder.cgColor
        crownImageView.image = UIImage(systemName: "crown.fill")
        crownImageView.tintColor = AppPalette.gold
        crownImageView.contentMode = .scaleAspectFit

        dealTitleLabel.font = UIFont.systemFont(ofSize: 9, weight: .bold)
        dealDiscountLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        dealDiscountLabel.textColor = AppPalette.gold
        dealDetailLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        dealDetailLabel.textColor = AppPalette.primaryText
        dealValidityLabel.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        dealValidityLabel.textColor = AppPalette.secondaryText

        var dealConfig = UIButton.Configuration.filled()
        dealConfig.baseBackgroundColor = AppPalette.gold
        dealConfig.baseForegroundColor = AppPalette.onGold
        dealConfig.background.cornerRadius = 10
        dealConfig.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        dealConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            return outgoing
        }
        viewDealButton.configuration = dealConfig
        viewDealButton.setTitle("View Deal", for: .normal)

        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.tintColor = .white
        favoriteButton.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        favoriteButton.layer.cornerRadius = 18
        favoriteButton.clipsToBounds = true
        favoriteButton.accessibilityLabel = "Favorite"

        bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        bookmarkButton.tintColor = AppPalette.primaryText
        bookmarkButton.backgroundColor = .clear
        bookmarkButton.accessibilityLabel = "Bookmark"

        favoriteButton.addTarget(self, action: #selector(handleFavorite), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(handleBookmark), for: .touchUpInside)
        viewDealButton.addTarget(self, action: #selector(handleDeal), for: .touchUpInside)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onFavorite = nil
        onBookmark = nil
        onViewDeal = nil
        heroImageView.image = nil
        wordmarkLabel.text = nil
    }

    func configure(with venue: Venue) {
        nameLabel.text = venue.name
        subtitleLabel.text = venue.subtitle
        wordmarkLabel.text = venue.wordmark
        verifiedImageView.isHidden = !venue.isVerified
        ratingLabel.attributedText = Self.ratingAttributedText(venue.ratingText)

        let imageSize = CGSize(width: ScreenMetrics.width(for: self) - 32, height: AppMetrics.heroHeight)
        heroImageView.image = ArtworkCache.image(for: venue, size: imageSize)

        updateFavorite(venue.isFavorite)
        updateBookmark(venue.isBookmarked)

        let showDeal = venue.deal != nil
        dealBannerView.isHidden = !showDeal
        dealHeightConstraint.constant = showDeal ? AppMetrics.dealHeight : 0
        dealTopConstraint.constant = showDeal ? 12 : 0

        if let deal = venue.deal {
            dealTitleLabel.attributedText = NSAttributedString(string: deal.badge, attributes: [
                .font: UIFont.systemFont(ofSize: 9, weight: .bold),
                .foregroundColor: AppPalette.gold,
                .kern: 1.0
            ])
            dealDiscountLabel.text = deal.discount
            dealDetailLabel.text = deal.detail
            dealValidityLabel.text = deal.validity
        }
    }

    private func updateFavorite(_ isFavorite: Bool) {
        let name = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: name), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemRed : .white
        favoriteButton.accessibilityValue = isFavorite ? "Saved" : "Not saved"
    }

    private func updateBookmark(_ isBookmarked: Bool) {
        let name = isBookmarked ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: name), for: .normal)
        bookmarkButton.tintColor = isBookmarked ? AppPalette.gold : AppPalette.primaryText
    }

    private static func ratingAttributedText(_ text: String) -> NSAttributedString {
        let star = NSTextAttachment()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        star.image = UIImage(systemName: "star.fill", withConfiguration: config)?
            .withTintColor(AppPalette.star, renderingMode: .alwaysOriginal)
        let result = NSMutableAttributedString(attachment: star)
        result.append(NSAttributedString(string: "  \(text)", attributes: [
            .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: AppPalette.primaryText
        ]))
        return result
    }

    @objc private func handleFavorite() {
        onFavorite?()
    }

    @objc private func handleBookmark() {
        onBookmark?()
    }

    @objc private func handleDeal() {
        onViewDeal?()
    }
}
