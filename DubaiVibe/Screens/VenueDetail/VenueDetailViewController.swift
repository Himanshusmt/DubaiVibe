import UIKit

final class VenueDetailViewController: UIViewController {
    private enum Metric {
        /// Cards and the hero share the same outer gutter.
        static let gutter: CGFloat = 12
        /// Text columns sit slightly inside the card edges, as in the design.
        static let textGutter: CGFloat = 18
        static let heroHeight: CGFloat = 210
        static let heroRadius: CGFloat = 20
        static let cardRadius: CGFloat = 16
    }

    private let repository: VenueDetailRepositorying
    private var detail: VenueDetail!
    private var selectedTab: VenueDetailTab = .deals
    private var isFavorite = false
    private var renderedHeroWidth: CGFloat = 0

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let heroImageView = HeroImageView(frame: .zero)
    private let wordmarkLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private let shareTopButton = UIButton(type: .system)
    private let favoriteButton = UIButton(type: .system)
    private let photosButton = UIButton(type: .system)
    private let vibeButton = UIButton(type: .system)

    private let nameLabel = UILabel()
    private let verifiedImageView = UIImageView()
    private let subtitleLabel = UILabel()
    private let ratingLabel = UILabel()
    private let brandTileLabel = UILabel()

    private let addressLabel = UILabel()
    private let hoursLabel = UILabel()

    private lazy var segmentCollection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.showsHorizontalScrollIndicator = false
        view.register(VenueDetailSegmentCell.self, forCellWithReuseIdentifier: VenueDetailSegmentCell.reuseIdentifier)
        view.dataSource = self
        view.delegate = self
        return view
    }()

    private let tabContentContainer = UIView()

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
        buildLayout()
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

// MARK: - Layout

private extension VenueDetailViewController {
    func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        let hero = makeHero()
        contentStack.addArrangedSubview(hero)
        contentStack.setCustomSpacing(14, after: hero)

        let info = makeInfoSection()
        contentStack.addArrangedSubview(info)
        contentStack.setCustomSpacing(12, after: info)

        contentStack.addArrangedSubview(segmentCollection)
        segmentCollection.heightAnchor.constraint(equalToConstant: 42).isActive = true
        contentStack.setCustomSpacing(10, after: segmentCollection)

        contentStack.addArrangedSubview(tabContentContainer)
        contentStack.setCustomSpacing(14, after: tabContentContainer)

        let meta = makeMetaCard()
        contentStack.addArrangedSubview(meta)
        contentStack.setCustomSpacing(20, after: meta)

        contentStack.addArrangedSubview(makeActionsSection())

        let tail = UIView()
        contentStack.addArrangedSubview(tail)
        tail.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }

    // MARK: Hero

    func makeHero() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        heroImageView.layer.cornerRadius = Metric.heroRadius
        heroImageView.layer.cornerCurve = .continuous
        heroImageView.backgroundColor = AppPalette.surface
        heroImageView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(heroImageView)

        wordmarkLabel.textColor = .white
        wordmarkLabel.font = UIFont.systemFont(ofSize: 44, weight: .bold)
        wordmarkLabel.textAlignment = .right
        wordmarkLabel.adjustsFontSizeToFitWidth = true
        wordmarkLabel.minimumScaleFactor = 0.4
        wordmarkLabel.translatesAutoresizingMaskIntoConstraints = false
        heroImageView.addSubview(wordmarkLabel)

        styleCircleButton(backButton, symbol: "chevron.left")
        styleCircleButton(shareTopButton, symbol: "square.and.arrow.up")
        styleCircleButton(favoriteButton, symbol: "heart")
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        shareTopButton.addTarget(self, action: #selector(handleShare), for: .touchUpInside)
        favoriteButton.addTarget(self, action: #selector(handleFavorite), for: .touchUpInside)

        heroImageView.addSubview(backButton)
        heroImageView.addSubview(shareTopButton)
        heroImageView.addSubview(favoriteButton)

        stylePillButton(photosButton, symbol: "photo.on.rectangle", title: "120 Photos")
        configureVibeButton()
        photosButton.addTarget(self, action: #selector(handleSoon(_:)), for: .touchUpInside)
        vibeButton.addTarget(self, action: #selector(handleSoon(_:)), for: .touchUpInside)
        heroImageView.addSubview(photosButton)
        heroImageView.addSubview(vibeButton)

        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: container.topAnchor, constant: 6),
            heroImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Metric.gutter),
            heroImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Metric.gutter),
            heroImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            heroImageView.heightAnchor.constraint(equalToConstant: Metric.heroHeight),

            backButton.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor, constant: 12),
            backButton.topAnchor.constraint(equalTo: heroImageView.topAnchor, constant: 12),
            backButton.widthAnchor.constraint(equalToConstant: 36),
            backButton.heightAnchor.constraint(equalToConstant: 36),

            favoriteButton.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor, constant: -12),
            favoriteButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: 36),
            favoriteButton.heightAnchor.constraint(equalToConstant: 36),

            shareTopButton.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -10),
            shareTopButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            shareTopButton.widthAnchor.constraint(equalToConstant: 36),
            shareTopButton.heightAnchor.constraint(equalToConstant: 36),

            wordmarkLabel.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor, constant: -18),
            wordmarkLabel.centerYAnchor.constraint(equalTo: heroImageView.centerYAnchor, constant: -8),
            wordmarkLabel.leadingAnchor.constraint(greaterThanOrEqualTo: heroImageView.centerXAnchor, constant: -20),

            photosButton.leadingAnchor.constraint(equalTo: heroImageView.leadingAnchor, constant: 12),
            photosButton.bottomAnchor.constraint(equalTo: heroImageView.bottomAnchor, constant: -14),
            photosButton.heightAnchor.constraint(equalToConstant: 36),

            vibeButton.trailingAnchor.constraint(equalTo: heroImageView.trailingAnchor, constant: -12),
            vibeButton.centerYAnchor.constraint(equalTo: photosButton.centerYAnchor),
            vibeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        return container
    }

    // MARK: Title block

    func makeInfoSection() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        nameLabel.textColor = AppPalette.primaryText
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        verifiedImageView.image = UIImage(systemName: "checkmark.seal.fill")
        verifiedImageView.tintColor = AppPalette.verified
        verifiedImageView.contentMode = .scaleAspectFit
        verifiedImageView.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        subtitleLabel.textColor = AppPalette.detailSubtitle
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        ratingLabel.translatesAutoresizingMaskIntoConstraints = false

        brandTileLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        brandTileLabel.textColor = AppPalette.gold
        brandTileLabel.textAlignment = .center
        brandTileLabel.adjustsFontSizeToFitWidth = true
        brandTileLabel.minimumScaleFactor = 0.5
        brandTileLabel.backgroundColor = AppPalette.detailCardFill
        brandTileLabel.layer.cornerRadius = 14
        brandTileLabel.layer.cornerCurve = .continuous
        brandTileLabel.layer.borderWidth = 1
        brandTileLabel.layer.borderColor = AppPalette.gold.withAlphaComponent(0.7).cgColor
        brandTileLabel.clipsToBounds = true
        brandTileLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(nameLabel)
        container.addSubview(verifiedImageView)
        container.addSubview(subtitleLabel)
        container.addSubview(ratingLabel)
        container.addSubview(brandTileLabel)

        NSLayoutConstraint.activate([
            brandTileLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -Metric.textGutter),
            brandTileLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            brandTileLabel.widthAnchor.constraint(equalToConstant: 80),
            brandTileLabel.heightAnchor.constraint(equalToConstant: 72),

            nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: Metric.textGutter),
            nameLabel.topAnchor.constraint(equalTo: container.topAnchor),

            verifiedImageView.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 7),
            verifiedImageView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor, constant: 1),
            verifiedImageView.widthAnchor.constraint(equalToConstant: 19),
            verifiedImageView.heightAnchor.constraint(equalToConstant: 19),
            verifiedImageView.trailingAnchor.constraint(lessThanOrEqualTo: brandTileLabel.leadingAnchor, constant: -10),

            subtitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: brandTileLabel.leadingAnchor, constant: -10),

            ratingLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            ratingLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 6),
            ratingLabel.trailingAnchor.constraint(lessThanOrEqualTo: brandTileLabel.leadingAnchor, constant: -10),

            container.bottomAnchor.constraint(greaterThanOrEqualTo: ratingLabel.bottomAnchor),
            container.bottomAnchor.constraint(greaterThanOrEqualTo: brandTileLabel.bottomAnchor)
        ])
        return container
    }

    // MARK: Address + hours card

    func makeMetaCard() -> UIView {
        let card = UIView()
        card.backgroundColor = AppPalette.detailCardFill
        card.layer.cornerRadius = Metric.cardRadius
        card.layer.cornerCurve = .continuous
        card.layer.borderWidth = 1
        card.layer.borderColor = AppPalette.detailCardBorder.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        let locationRow = makeLocationRow()
        let hoursRow = makeHoursRow()

        let divider = UIView()
        divider.backgroundColor = AppPalette.detailCardBorder
        divider.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(locationRow)
        card.addSubview(divider)
        card.addSubview(hoursRow)

        NSLayoutConstraint.activate([
            locationRow.topAnchor.constraint(equalTo: card.topAnchor),
            locationRow.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            locationRow.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            locationRow.heightAnchor.constraint(equalToConstant: 46),

            divider.topAnchor.constraint(equalTo: locationRow.bottomAnchor),
            divider.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),

            hoursRow.topAnchor.constraint(equalTo: divider.bottomAnchor),
            hoursRow.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            hoursRow.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            hoursRow.heightAnchor.constraint(equalToConstant: 46),
            hoursRow.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        return wrap(card, inset: Metric.gutter)
    }

    func makeLocationRow() -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        icon.tintColor = AppPalette.gold
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        addressLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        addressLabel.textColor = AppPalette.primaryText
        addressLabel.translatesAutoresizingMaskIntoConstraints = false

        let directions = UIButton(type: .system)
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
        directions.configuration = config
        directions.addTarget(self, action: #selector(handleDirections), for: .touchUpInside)
        directions.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(icon)
        row.addSubview(addressLabel)
        row.addSubview(directions)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),

            directions.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -10),
            directions.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            addressLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            addressLabel.trailingAnchor.constraint(lessThanOrEqualTo: directions.leadingAnchor, constant: -8),
            addressLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        return row
    }

    func makeHoursRow() -> UIView {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let icon = UIImageView(image: UIImage(systemName: "clock"))
        icon.tintColor = AppPalette.gold
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        hoursLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        hoursLabel.textColor = AppPalette.primaryText
        hoursLabel.translatesAutoresizingMaskIntoConstraints = false

        let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevron.tintColor = AppPalette.gold
        chevron.contentMode = .scaleAspectFit
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let hit = UIButton(type: .system)
        hit.translatesAutoresizingMaskIntoConstraints = false
        hit.addTarget(self, action: #selector(handleHours), for: .touchUpInside)

        row.addSubview(icon)
        row.addSubview(hoursLabel)
        row.addSubview(chevron)
        row.addSubview(hit)

        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14),
            icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20),

            chevron.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 14),
            chevron.heightAnchor.constraint(equalToConstant: 14),

            hoursLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 10),
            hoursLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -8),
            hoursLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            hit.topAnchor.constraint(equalTo: row.topAnchor),
            hit.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            hit.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            hit.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        return row
    }

    // MARK: Quick actions

    func makeActionsSection() -> UIView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.alignment = .top
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        let items: [(UIImage?, String, Selector)] = [
            (UIImage(systemName: "phone.fill"), "Call", #selector(handleCall)),
            (UIImage(systemName: "globe"), "Website", #selector(handleWebsite)),
            (BrandGlyphs.instagram, "Instagram", #selector(handleInstagram)),
            (nil, "OneVibe", #selector(handleSoon(_:))),
            (BrandGlyphs.shareNodes, "Share", #selector(handleShare))
        ]
        for (image, title, action) in items {
            stack.addArrangedSubview(makeActionItem(image: image, title: title, action: action))
        }

        return wrap(stack, inset: 14)
    }

    func makeActionItem(image: UIImage?, title: String, action: Selector) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8

        let button = UIButton(type: .system)
        button.tintColor = AppPalette.gold
        button.backgroundColor = AppPalette.detailCardFill
        button.layer.cornerRadius = 27
        button.layer.borderWidth = 1
        button.layer.borderColor = AppPalette.gold.withAlphaComponent(0.35).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 54).isActive = true
        button.heightAnchor.constraint(equalToConstant: 54).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        button.accessibilityLabel = title

        if let image {
            button.setImage(image.withConfiguration(UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)), for: .normal)
        } else {
            // OneVibe uses the brand mark rather than a symbol.
            let logo = UIImageView(image: UIImage(named: "LaunchLogo"))
            logo.contentMode = .scaleAspectFit
            logo.clipsToBounds = true
            logo.layer.cornerRadius = 20
            logo.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(logo)
            NSLayoutConstraint.activate([
                logo.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                logo.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                logo.widthAnchor.constraint(equalToConstant: 40),
                logo.heightAnchor.constraint(equalToConstant: 40)
            ])
        }

        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = AppPalette.primaryText
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8

        stack.addArrangedSubview(button)
        stack.addArrangedSubview(label)
        return stack
    }

    // MARK: Shared styling

    func wrap(_ child: UIView, inset: CGFloat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        child.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(child)
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: inset),
            child.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -inset),
            child.topAnchor.constraint(equalTo: container.topAnchor),
            child.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        return container
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
        button.translatesAutoresizingMaskIntoConstraints = false
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
        button.translatesAutoresizingMaskIntoConstraints = false
    }

    /// "Watch Vibe" keeps the play glyph inside a solid white disc.
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
        vibeButton.translatesAutoresizingMaskIntoConstraints = false

        let disc = UIView()
        disc.backgroundColor = .white
        disc.layer.cornerRadius = 13
        disc.isUserInteractionEnabled = false
        disc.translatesAutoresizingMaskIntoConstraints = false

        let play = UIImageView(image: UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .black)))
        play.tintColor = .black
        play.contentMode = .scaleAspectFit
        play.translatesAutoresizingMaskIntoConstraints = false

        vibeButton.addSubview(disc)
        disc.addSubview(play)

        NSLayoutConstraint.activate([
            disc.trailingAnchor.constraint(equalTo: vibeButton.trailingAnchor, constant: -6),
            disc.centerYAnchor.constraint(equalTo: vibeButton.centerYAnchor),
            disc.widthAnchor.constraint(equalToConstant: 26),
            disc.heightAnchor.constraint(equalToConstant: 26),

            play.centerXAnchor.constraint(equalTo: disc.centerXAnchor, constant: 1),
            play.centerYAnchor.constraint(equalTo: disc.centerYAnchor),
            play.widthAnchor.constraint(equalToConstant: 12),
            play.heightAnchor.constraint(equalToConstant: 12)
        ])
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
    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc func handleFavorite() {
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

    @objc func handleShare() {
        guard let detail else { return }
        let items: [Any] = ["\(detail.name) — \(detail.subtitle)", detail.website]
        present(UIActivityViewController(activityItems: items, applicationActivities: nil), animated: true)
    }

    @objc func handleUnlockDeal() {
        presentAlert(title: "Deal unlocked", message: "Show this offer at the venue. Full redemption flow coming soon.")
    }

    @objc func handleDirections() {
        presentAlert(title: "Directions", message: detail?.address ?? "")
    }

    @objc func handleHours() {
        presentAlert(title: "Opening hours", message: detail?.hoursText ?? "")
    }

    @objc func handleCall() {
        presentAlert(title: "Call", message: detail?.phone ?? "")
    }

    @objc func handleWebsite() {
        presentAlert(title: "Website", message: detail?.website ?? "")
    }

    @objc func handleInstagram() {
        presentAlert(title: "Instagram", message: "@\(detail?.instagram ?? "")")
    }

    @objc func handleSoon(_ sender: UIButton) {
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
