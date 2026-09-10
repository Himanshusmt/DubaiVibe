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
    @IBOutlet private weak var viewDealButton: GoldGradientButton!
    @IBOutlet private weak var dealHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dealTopConstraint: NSLayoutConstraint!

    private let dealFill = GoldGradientView()
    private let dealBorder = GradientBorderView()
    private let heroFade = GoldGradientView()

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

        cardView.backgroundColor = AppPalette.cardFill
        cardView.layer.cornerRadius = AppMetrics.cardRadius
        cardView.layer.cornerCurve = .continuous
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = AppPalette.cardBorder.cgColor
        cardView.clipsToBounds = true

        heroImageView.contentMode = .scaleAspectFill
        heroImageView.clipsToBounds = true
        heroImageView.isOpaque = false

        heroFade.kind = .heroFade
        heroImageView.addSubview(heroFade)
        heroFade.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heroFade.topAnchor.constraint(equalTo: heroImageView.topAnchor),
            heroFade.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor),
            heroFade.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor),
            heroFade.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor)
        ])

        wordmarkLabel.textColor = .white
        wordmarkLabel.font = AppTypography.font(.bold, size: 24)
        wordmarkLabel.adjustsFontSizeToFitWidth = true
        wordmarkLabel.minimumScaleFactor = 0.45
        wordmarkLabel.textAlignment = .center
        wordmarkLabel.layer.shadowColor = UIColor.black.cgColor
        wordmarkLabel.layer.shadowOpacity = 0.4
        wordmarkLabel.layer.shadowRadius = 8
        wordmarkLabel.layer.shadowOffset = .zero

        nameLabel.font = AppTypography.font(.bold, size: 15)
        nameLabel.textColor = AppPalette.primaryText
        subtitleLabel.font = AppTypography.font(.medium, size: 11.5)
        subtitleLabel.textColor = AppPalette.secondaryText

        let verifiedConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .regular)
        verifiedImageView.image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: verifiedConfig)
        verifiedImageView.tintColor = AppPalette.verified
        verifiedImageView.contentMode = .scaleAspectFit

        dealBannerView.backgroundColor = .clear
        dealBannerView.layer.cornerRadius = 12
        dealBannerView.layer.cornerCurve = .continuous
        dealBannerView.layer.borderWidth = 0
        dealBannerView.clipsToBounds = true

        // Fill: #FFA903 @17% → #0B0B0C
        dealFill.kind = .dealPanel
        dealFill.layer.cornerRadius = 12
        dealFill.layer.cornerCurve = .continuous
        dealFill.layer.shadowOpacity = 0.1
        dealFill.clipsToBounds = true
        dealBannerView.insertSubview(dealFill, at: 0)
        dealFill.translatesAutoresizingMaskIntoConstraints = false
        // Border: 1px inner #FCE19B → #E2A645 → #B87B22
        dealBorder.lineWidth = 1
        dealBorder.layer.cornerRadius = 12
        dealBorder.layer.cornerCurve = .continuous
        dealBannerView.addSubview(dealBorder)
        dealBorder.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dealFill.topAnchor.constraint(equalTo: dealBannerView.topAnchor),
            dealFill.leadingAnchor.constraint(equalTo: dealBannerView.leadingAnchor),
            dealFill.trailingAnchor.constraint(equalTo: dealBannerView.trailingAnchor),
            dealFill.bottomAnchor.constraint(equalTo: dealBannerView.bottomAnchor),
            dealBorder.topAnchor.constraint(equalTo: dealBannerView.topAnchor),
            dealBorder.leadingAnchor.constraint(equalTo: dealBannerView.leadingAnchor),
            dealBorder.trailingAnchor.constraint(equalTo: dealBannerView.trailingAnchor),
            dealBorder.bottomAnchor.constraint(equalTo: dealBannerView.bottomAnchor)
        ])

        crownBackgroundView.backgroundColor = AppPalette.crownFill
        crownBackgroundView.layer.cornerRadius = 8
        crownBackgroundView.layer.cornerCurve = .continuous
        crownBackgroundView.layer.borderWidth = 1
        crownBackgroundView.layer.borderColor = AppPalette.gold.withAlphaComponent(0.6).cgColor
        crownImageView.image = UIImage(named: "ExploreCrown")
        crownImageView.tintColor = nil
        crownImageView.contentMode = .scaleAspectFit

        dealTitleLabel.font = AppTypography.font(.semibold, size: 8.5)
        dealDiscountLabel.font = AppTypography.font(.bold, size: 17)
        dealDiscountLabel.textColor = AppPalette.primaryText
        dealDetailLabel.font = AppTypography.font(.regular, size: 10)
        dealDetailLabel.textColor = AppPalette.dealDetailText
        dealValidityLabel.font = AppTypography.font(.regular, size: 9.5)
        dealValidityLabel.textColor = AppPalette.secondaryText

        // Figma View Deal button: #F3CE85 → #D8A04D (diagonal)
        viewDealButton.backgroundColor = .clear
        viewDealButton.layer.cornerRadius = 12
        viewDealButton.layer.cornerCurve = .continuous
        viewDealButton.clipsToBounds = true
        viewDealButton.setTitle("View Deal", for: .normal)
        viewDealButton.setTitleColor(AppPalette.onGold, for: .normal)
        viewDealButton.titleLabel?.font = AppTypography.font(.bold, size: 12)
        viewDealButton.tintColor = AppPalette.onGold
        viewDealButton.setNeedsLayout()
        viewDealButton.layoutIfNeeded()

        favoriteButton.setImage(UIImage(named: "ExploreHeart"), for: .normal)
        favoriteButton.tintColor = .white
        favoriteButton.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        favoriteButton.layer.cornerRadius = 16
        favoriteButton.clipsToBounds = true
        favoriteButton.accessibilityLabel = "Favorite"

        bookmarkButton.setImage(UIImage(named: "ExploreBookmark"), for: .normal)
        bookmarkButton.tintColor = nil
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
        nameLabel.attributedText = NSAttributedString(string: venue.name, attributes: [
            .font: AppTypography.font(.bold, size: 15),
            .foregroundColor: AppPalette.primaryText,
            .kern: -0.375
        ])
        subtitleLabel.text = venue.subtitle
        applyWordmark(venue)
        verifiedImageView.isHidden = !venue.isVerified
        ratingLabel.attributedText = Self.ratingAttributedText(for: venue)

        let cardWidth = ScreenMetrics.width(for: self) - AppMetrics.cardGutter * 2
        let imageSize = CGSize(width: cardWidth, height: AppMetrics.heroHeight)
        heroImageView.image = ArtworkCache.image(for: venue, size: imageSize)

        updateFavorite(venue.isFavorite)
        updateBookmark(venue.isBookmarked)

        let showDeal = venue.deal != nil
        dealBannerView.isHidden = !showDeal
        dealHeightConstraint.constant = showDeal ? AppMetrics.dealHeight : 0
        dealTopConstraint.constant = showDeal ? 12 : 0

        if let deal = venue.deal {
            dealTitleLabel.attributedText = NSAttributedString(string: deal.badge, attributes: [
                .font: AppTypography.font(.semibold, size: 8.5),
                .foregroundColor: AppPalette.exclusiveGold,
                .kern: 0.425
            ])
            dealDiscountLabel.text = deal.discount
            dealDetailLabel.text = deal.detail
            dealValidityLabel.text = deal.validity
        }
    }

    private func applyWordmark(_ venue: Venue) {
        let font: UIFont
        let kern: CGFloat
        if venue.artworkStyle == .rooftop {
            font = AppTypography.font(.bold, size: 18)
            kern = 4.5
        } else {
            font = AppTypography.font(.bold, size: 24)
            kern = -0.6
        }
        wordmarkLabel.attributedText = NSAttributedString(string: venue.wordmark, attributes: [
            .font: font,
            .foregroundColor: UIColor.white,
            .kern: kern
        ])
    }

    private func updateFavorite(_ isFavorite: Bool) {
        if isFavorite {
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            favoriteButton.tintColor = .systemRed
        } else {
            favoriteButton.setImage(UIImage(named: "ExploreHeart"), for: .normal)
            favoriteButton.tintColor = .white
        }
        favoriteButton.accessibilityValue = isFavorite ? "Saved" : "Not saved"
    }

    private func updateBookmark(_ isBookmarked: Bool) {
        if isBookmarked {
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            bookmarkButton.tintColor = AppPalette.gold
        } else {
            bookmarkButton.setImage(UIImage(named: "ExploreBookmark"), for: .normal)
            bookmarkButton.tintColor = nil
        }
    }

    private static func ratingAttributedText(for venue: Venue) -> NSAttributedString {
        let star = NSTextAttachment()
        let starImage = UIImage(named: "ExploreStar") ?? UIImage(systemName: "star.fill")
        star.image = starImage
        star.bounds = CGRect(x: 0, y: -1, width: 10.5, height: 10)

        let result = NSMutableAttributedString(attachment: star)
        result.append(NSAttributedString(string: " \(venue.ratingValueText)", attributes: [
            .font: AppTypography.font(.bold, size: 11),
            .foregroundColor: AppPalette.primaryText
        ]))
        result.append(NSAttributedString(string: " \(venue.reviewCountText)", attributes: [
            .font: AppTypography.font(.regular, size: 11),
            .foregroundColor: AppPalette.secondaryText
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
