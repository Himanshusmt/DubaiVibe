import UIKit

final class VenueDetailViewController: UIViewController {
    private enum Metric {
        static let gutter: CGFloat = 12
        static let heroHeight: CGFloat = 210
        static let heroRadius: CGFloat = 20
        static let cardRadius: CGFloat = 16
    }

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var heroImageView: HeroImageView!
    @IBOutlet private weak var wordmarkLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var shareTopButton: UIButton!
    @IBOutlet private weak var favoriteButton: UIButton!
    @IBOutlet private weak var photosButton: UIButton!
    @IBOutlet private weak var vibeButton: UIButton!
    @IBOutlet private weak var vibeDiscView: UIView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var verifiedImageView: UIImageView!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var brandTileLabel: UILabel!
    @IBOutlet private weak var segmentCollection: UICollectionView!
    @IBOutlet private weak var tabContentContainer: UIView!
    @IBOutlet private weak var metaCardView: UIView!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var hoursLabel: UILabel!
    @IBOutlet private weak var directionsButton: UIButton!
    @IBOutlet private weak var callButton: UIButton!
    @IBOutlet private weak var websiteButton: UIButton!
    @IBOutlet private weak var instagramButton: UIButton!
    @IBOutlet private weak var shareActionButton: UIButton!
    @IBOutlet private weak var oneVibeButton: UIButton!

    private let repository: VenueDetailRepositorying
    private var detail: VenueDetail!
    private var selectedTab: VenueDetailTab = .deals
    private var isFavorite = false
    private var renderedHeroWidth: CGFloat = 0

    init?(coder: NSCoder, repository: VenueDetailRepositorying) {
        self.repository = repository
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        self.repository = VenueDetailRepository()
        super.init(coder: coder)
    }

    func configure(venueID: UUID) {
        guard let detail = repository.detail(for: venueID) else { return }
        self.detail = detail
        selectedTab = detail.defaultTab
        if isViewLoaded {
            bind()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureChrome()
        if detail != nil {
            bind()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateHeroArtwork()
    }
}

// MARK: - Chrome

private extension VenueDetailViewController {
    func configureChrome() {
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never

        heroImageView.layer.cornerRadius = Metric.heroRadius
        heroImageView.layer.cornerCurve = .continuous
        heroImageView.backgroundColor = AppPalette.surface
        heroImageView.clipsToBounds = true

        styleCircleButton(backButton, symbol: "chevron.left")
        styleCircleButton(shareTopButton, symbol: "square.and.arrow.up")
        styleCircleButton(favoriteButton, symbol: "heart")

        stylePillButton(photosButton, symbol: "photo.on.rectangle", title: photosButton.currentTitle ?? "Photos")
        photosButton.accessibilityLabel = "Photos"
        configureVibeButton()
        vibeButton.accessibilityLabel = "Watch Vibe"
        vibeDiscView.layer.cornerRadius = 13

        brandTileLabel.backgroundColor = AppPalette.detailCardFill
        brandTileLabel.layer.cornerRadius = 14
        brandTileLabel.layer.cornerCurve = .continuous
        brandTileLabel.layer.borderWidth = 1
        brandTileLabel.layer.borderColor = AppPalette.gold.withAlphaComponent(0.7).cgColor
        brandTileLabel.clipsToBounds = true

        metaCardView.backgroundColor = AppPalette.detailCardFill
        metaCardView.layer.cornerRadius = Metric.cardRadius
        metaCardView.layer.cornerCurve = .continuous
        metaCardView.layer.borderWidth = 1
        metaCardView.layer.borderColor = AppPalette.detailCardBorder.cgColor

        styleDirectionsButton()
        [callButton, websiteButton, instagramButton, shareActionButton, oneVibeButton].forEach(styleActionButton)

        let symbol = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        instagramButton.setImage(BrandGlyphs.instagram.withConfiguration(symbol), for: .normal)
        shareActionButton.setImage(BrandGlyphs.shareNodes.withConfiguration(symbol), for: .normal)
        oneVibeButton.accessibilityLabel = "OneVibe"
        oneVibeButton.imageView?.contentMode = .scaleAspectFit
        oneVibeButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        oneVibeButton.clipsToBounds = true
    }

    func styleCircleButton(_ button: UIButton, symbol: String) {
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        button.setImage(UIImage(systemName: symbol, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.42)
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        button.clipsToBounds = true
    }

    func stylePillButton(_ button: UIButton, symbol: String, title: String) {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.black.withAlphaComponent(0.62)
        config.baseForegroundColor = .white
        config.image = UIImage(systemName: symbol, withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .regular))
        config.title = title
        config.imagePadding = 7
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 13, bottom: 8, trailing: 15)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            return outgoing
        }
        button.configuration = config
    }

    func configureVibeButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = UIColor.black.withAlphaComponent(0.62)
        config.baseForegroundColor = .white
        config.title = "Watch Vibe"
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 44)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            return outgoing
        }
        vibeButton.configuration = config
    }

    func styleDirectionsButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        config.title = "Directions"
        config.imagePadding = 6
        config.baseForegroundColor = AppPalette.primaryText
        config.background.strokeColor = AppPalette.gold.withAlphaComponent(0.55)
        config.background.strokeWidth = 1
        config.background.cornerRadius = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 12, bottom: 7, trailing: 12)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12.5, weight: .medium)
            return outgoing
        }
        directionsButton.configuration = config
    }

    func styleActionButton(_ button: UIButton) {
        button.tintColor = AppPalette.gold
        button.backgroundColor = AppPalette.detailCardFill
        button.layer.cornerRadius = 27
        button.layer.borderWidth = 1
        button.layer.borderColor = AppPalette.gold.withAlphaComponent(0.35).cgColor
    }
}

// MARK: - Binding

private extension VenueDetailViewController {
    func bind() {
        guard let detail else { return }

        renderedHeroWidth = 0
        updateHeroArtwork()

        wordmarkLabel.text = detail.wordmark
        nameLabel.text = detail.name
        verifiedImageView.isHidden = !detail.isVerified
        subtitleLabel.text = detail.subtitle
        ratingLabel.attributedText = ratingAttributedText(
            value: detail.ratingValueText,
            count: detail.reviewCountText
        )
        brandTileLabel.text = detail.wordmark
        photosButton.configuration?.title = detail.photoCountText
        addressLabel.text = detail.address
        hoursLabel.text = detail.hoursText

        segmentCollection.reloadData()
        renderTabContent()
        updateFavoriteIcon()
    }

    /// Renders the hero artwork once the real card width is known.
    func updateHeroArtwork() {
        guard let detail else { return }
        let width = heroImageView.bounds.width
        guard width > 1, width != renderedHeroWidth else { return }
        renderedHeroWidth = width

        let venue = Venue(
            id: detail.venueID,
            name: detail.name,
            wordmark: detail.wordmark,
            category: .restaurants,
            cuisine: detail.cuisine,
            neighborhood: detail.neighborhood,
            rating: detail.rating,
            reviewCount: detail.reviewCount,
            deal: nil,
            isFavorite: false,
            isBookmarked: false,
            isVerified: detail.isVerified,
            artworkStyle: detail.artworkStyle
        )
        heroImageView.image = ArtworkCache.image(
            for: venue,
            size: CGSize(width: width, height: Metric.heroHeight)
        )
    }

    func ratingAttributedText(value: String, count: String) -> NSAttributedString {
        let star = NSTextAttachment()
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        star.image = UIImage(systemName: "star.fill", withConfiguration: config)?
            .withTintColor(AppPalette.star, renderingMode: .alwaysOriginal)
        star.bounds = CGRect(x: 0, y: -2.5, width: 17, height: 16)

        let result = NSMutableAttributedString(attachment: star)
        result.append(NSAttributedString(string: "  \(value)  ", attributes: [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            .foregroundColor: AppPalette.primaryText
        ]))
        result.append(NSAttributedString(string: count, attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: AppPalette.detailSubtitle
        ]))
        return result
    }

    func renderTabContent() {
        tabContentContainer.subviews.forEach { $0.removeFromSuperview() }

        let content: UIView
        switch selectedTab {
        case .deals:
            content = makeDealsContent()
        case .about:
            content = makePlainContent(title: "About", body: detail.aboutText)
        case .menu:
            content = makePlainContent(title: "Menu", body: "Full menu coming soon. Seasonal specials and signature dishes will appear here.")
        case .vibes:
            content = makePlainContent(title: "Vibes", body: "Watch Vibe videos and guest moments will appear here.")
        case .reviews:
            content = makePlainContent(title: "Reviews", body: "Guest reviews and ratings breakdown will appear here.")
        }

        content.translatesAutoresizingMaskIntoConstraints = false
        tabContentContainer.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: tabContentContainer.topAnchor),
            content.leadingAnchor.constraint(equalTo: tabContentContainer.leadingAnchor, constant: Metric.gutter),
            content.trailingAnchor.constraint(equalTo: tabContentContainer.trailingAnchor, constant: -Metric.gutter),
            content.bottomAnchor.constraint(equalTo: tabContentContainer.bottomAnchor)
        ])
    }

    func makePlainContent(title: String, body: String) -> UIView {
        let card = UIView()
        card.backgroundColor = AppPalette.detailCardFill
        card.layer.cornerRadius = Metric.cardRadius
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = AppPalette.detailCardBorder.cgColor

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = AppPalette.primaryText
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = AppPalette.secondaryText
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(titleLabel)
        card.addSubview(bodyLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    func makeDealsContent() -> UIView {
        guard let deal = detail.deal else {
            return makePlainContent(title: "Deals", body: "No exclusive deals available for this venue right now.")
        }

        let card = UIView()
        card.backgroundColor = AppPalette.dealCardFill
        card.layer.cornerRadius = 18
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = AppPalette.dealCardBorder.cgColor

        let crownBox = UIView()
        crownBox.backgroundColor = AppPalette.crownFill
        crownBox.layer.cornerRadius = 14
        crownBox.layer.cornerCurve = .continuous
        crownBox.layer.borderWidth = 1
        crownBox.layer.borderColor = AppPalette.gold.withAlphaComponent(0.75).cgColor
        crownBox.translatesAutoresizingMaskIntoConstraints = false

        let crown = UIImageView(image: UIImage(systemName: "crown.fill"))
        crown.tintColor = AppPalette.gold
        crown.contentMode = .scaleAspectFit
        crown.translatesAutoresizingMaskIntoConstraints = false
        crownBox.addSubview(crown)

        let badge = UILabel()
        badge.attributedText = NSAttributedString(string: deal.badge, attributes: [
            .font: UIFont.systemFont(ofSize: 11.5, weight: .semibold),
            .foregroundColor: AppPalette.gold,
            .kern: 1.3
        ])
        badge.translatesAutoresizingMaskIntoConstraints = false

        let discount = UILabel()
        discount.text = deal.discount
        discount.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        discount.textColor = AppPalette.gold
        discount.adjustsFontSizeToFitWidth = true
        discount.minimumScaleFactor = 0.6
        discount.translatesAutoresizingMaskIntoConstraints = false

        let detailLabel = UILabel()
        detailLabel.text = deal.detail
        detailLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        detailLabel.textColor = AppPalette.primaryText
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        let termsStack = UIStackView()
        termsStack.axis = .vertical
        termsStack.spacing = 12
        termsStack.alignment = .fill
        termsStack.translatesAutoresizingMaskIntoConstraints = false
        for term in deal.terms {
            termsStack.addArrangedSubview(makeTermRow(term))
        }

        let unlock = GoldGradientButton(type: .system)
        unlock.setTitle(deal.ctaTitle, for: .normal)
        unlock.setTitleColor(AppPalette.onGold, for: .normal)
        unlock.titleLabel?.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        unlock.addTarget(self, action: #selector(handleUnlockDeal), for: .touchUpInside)
        unlock.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(crownBox)
        card.addSubview(badge)
        card.addSubview(discount)
        card.addSubview(detailLabel)
        card.addSubview(termsStack)
        card.addSubview(unlock)

        NSLayoutConstraint.activate([
            crownBox.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            crownBox.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            crownBox.widthAnchor.constraint(equalToConstant: 72),
            crownBox.heightAnchor.constraint(equalToConstant: 72),
            crown.centerXAnchor.constraint(equalTo: crownBox.centerXAnchor),
            crown.centerYAnchor.constraint(equalTo: crownBox.centerYAnchor),
            crown.widthAnchor.constraint(equalToConstant: 36),
            crown.heightAnchor.constraint(equalToConstant: 30),

            badge.leadingAnchor.constraint(equalTo: crownBox.trailingAnchor, constant: 16),
            badge.topAnchor.constraint(equalTo: crownBox.topAnchor, constant: 4),
            badge.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -14),

            discount.leadingAnchor.constraint(equalTo: badge.leadingAnchor),
            discount.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 1),
            discount.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -14),

            detailLabel.leadingAnchor.constraint(equalTo: badge.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: discount.bottomAnchor, constant: 0),
            detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: card.trailingAnchor, constant: -14),

            termsStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            termsStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            termsStack.topAnchor.constraint(equalTo: crownBox.bottomAnchor, constant: 24),

            unlock.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            unlock.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            unlock.topAnchor.constraint(equalTo: termsStack.bottomAnchor, constant: 22),
            unlock.heightAnchor.constraint(equalToConstant: 48),
            unlock.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        return card
    }

    func makeTermRow(_ term: DealTerm) -> UIView {
        let row = UIView()

        let icon = UIImageView(image: UIImage(
            systemName: term.symbolName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        ))
        icon.tintColor = AppPalette.primaryText
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = term.text
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = AppPalette.primaryText
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(icon)
        row.addSubview(label)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            icon.centerYAnchor.constraint(equalTo: label.firstBaselineAnchor, constant: -5),
            icon.widthAnchor.constraint(equalToConstant: 19),
            icon.heightAnchor.constraint(equalToConstant: 19),

            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            label.topAnchor.constraint(equalTo: row.topAnchor),
            label.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        return row
    }
}

// MARK: - Actions

private extension VenueDetailViewController {
    @IBAction func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func handleFavorite() {
        isFavorite.toggle()
        updateFavoriteIcon()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func updateFavoriteIcon() {
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
        let name = isFavorite ? "heart.fill" : "heart"
        favoriteButton.setImage(UIImage(systemName: name, withConfiguration: config), for: .normal)
        favoriteButton.tintColor = isFavorite ? .systemRed : .white
    }

    @IBAction func handleShare() {
        guard let detail else { return }
        let items: [Any] = ["\(detail.name) — \(detail.subtitle)", detail.website]
        present(UIActivityViewController(activityItems: items, applicationActivities: nil), animated: true)
    }

    @IBAction func handleUnlockDeal() {
        let storyboard = UIStoryboard(name: "MembershipVerification", bundle: nil)
        guard let controller = storyboard.instantiateInitialViewController() as? MembershipVerificationViewController else {
            return
        }
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func handleDirections() {
        presentAlert(title: "Directions", message: detail?.address ?? "")
    }

    @IBAction func handleHours() {
        presentAlert(title: "Opening hours", message: detail?.hoursText ?? "")
    }

    @IBAction func handleCall() {
        presentAlert(title: "Call", message: detail?.phone ?? "")
    }

    @IBAction func handleWebsite() {
        presentAlert(title: "Website", message: detail?.website ?? "")
    }

    @IBAction func handleInstagram() {
        presentAlert(title: "Instagram", message: "@\(detail?.instagram ?? "")")
    }

    @IBAction func handleSoon(_ sender: UIButton) {
        let title = sender.accessibilityLabel ?? sender.configuration?.title ?? "Coming soon"
        presentAlert(title: title, message: "Coming soon")
    }

    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Tab strip

extension VenueDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        VenueDetailTab.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VenueDetailSegmentCell.reuseIdentifier,
            for: indexPath
        ) as? VenueDetailSegmentCell else {
            return UICollectionViewCell()
        }
        let tab = VenueDetailTab.allCases[indexPath.item]
        cell.configure(title: tab.title, selected: tab == selectedTab)
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // Five tabs share the full width, matching the design's even spread.
        let count = CGFloat(VenueDetailTab.allCases.count)
        let width = (collectionView.bounds.width / count).rounded(.down)
        return CGSize(width: max(width, 1), height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedTab = VenueDetailTab.allCases[indexPath.item]
        collectionView.reloadData()
        renderTabContent()
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
