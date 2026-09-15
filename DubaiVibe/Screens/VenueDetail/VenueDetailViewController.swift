import UIKit
import MapKit
import CoreLocation

final class VenueDetailViewController: UIViewController {
    private enum Metric {
        static let gutter: CGFloat = 12
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
    private let brandLogoImageView = UIImageView()

    @IBOutlet private weak var segmentCollection: UICollectionView!
    @IBOutlet private weak var segmentCollectionHeight: NSLayoutConstraint!
    @IBOutlet private weak var tabContentTopSpacing: NSLayoutConstraint!
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

    private let viewModel = VenueDetailViewModel()
    private var businessID = ""
    private var detail: VenueDetail?
    private var selectedTab: VenueDetailTab = .deals
    private var isFavorite = false
    private var isHoursExpanded = false
    private weak var hoursChevronImageView: UIImageView?
    private let hoursWeekdayLabel = UILabel()
    private var hoursCollapsedBottomConstraint: NSLayoutConstraint?
    private var hoursExpandedBottomConstraint: NSLayoutConstraint?
    private var didSetupHoursDropdown = false

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(businessID: String) {
        self.businessID = businessID
        if isViewLoaded {
            fetchDetail()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureChrome()
        fetchDetail()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        heroImageView.startAutoScroll()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        heroImageView.stopAutoScroll()
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

        stylePillButton(photosButton, symbol: "photo.on.rectangle", title: L10n.photos)
        photosButton.accessibilityLabel = L10n.photos
        photosButton.removeTarget(nil, action: nil, for: .touchUpInside)
        photosButton.addTarget(self, action: #selector(handlePhotos), for: .touchUpInside)
        wordmarkLabel.isHidden = true
        vibeButton.isHidden = true
        vibeDiscView.isHidden = true

        brandTileLabel.backgroundColor = AppPalette.detailCardFill
        brandTileLabel.layer.cornerRadius = 14
        brandTileLabel.layer.cornerCurve = .continuous
        brandTileLabel.layer.borderWidth = 1
        brandTileLabel.layer.borderColor = AppPalette.gold.withAlphaComponent(0.7).cgColor
        brandTileLabel.clipsToBounds = true
        brandTileLabel.text = nil
        brandTileLabel.textAlignment = .center
        configureBrandLogoImageView()

        configureWrappingLabels()

        metaCardView.backgroundColor = AppPalette.detailCardFill
        metaCardView.layer.cornerRadius = Metric.cardRadius
        metaCardView.layer.cornerCurve = .continuous
        metaCardView.layer.borderWidth = 1
        metaCardView.layer.borderColor = AppPalette.detailCardBorder.cgColor

        styleDirectionsButton()
        [callButton, websiteButton, instagramButton, shareActionButton, oneVibeButton].forEach(styleActionButton)
        hideSegmentCollection()
        applyLocalizedStoryboardCopy()

        let symbol = UIImage.SymbolConfiguration(pointSize: 21, weight: .regular)
        instagramButton.setImage(BrandGlyphs.instagram.withConfiguration(symbol), for: .normal)
        shareActionButton.setImage(BrandGlyphs.shareNodes.withConfiguration(symbol), for: .normal)
        oneVibeButton.accessibilityLabel = L10n.oneVibe
        oneVibeButton.imageView?.contentMode = .scaleAspectFit
        oneVibeButton.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        oneVibeButton.clipsToBounds = true
    }

    func configureWrappingLabels() {
        [nameLabel, subtitleLabel].forEach { label in
            label?.numberOfLines = 2
            label?.lineBreakMode = .byWordWrapping
            label?.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        nameLabel.adjustsFontSizeToFitWidth = false

        // Address wraps beside a fixed Directions button (matches design screenshot).
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byWordWrapping
        addressLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        addressLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        addressLabel.setContentHuggingPriority(.required, for: .vertical)
        addressLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        hoursLabel.numberOfLines = 2
        hoursLabel.lineBreakMode = .byWordWrapping
        hoursLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        hoursLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        directionsButton.setContentHuggingPriority(.required, for: .horizontal)
        directionsButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        directionsButton.setContentHuggingPriority(.required, for: .vertical)
        directionsButton.setContentCompressionResistancePriority(.required, for: .vertical)

        configureMetaCardLayout()
    }

    func configureBrandLogoImageView() {
        brandLogoImageView.translatesAutoresizingMaskIntoConstraints = false
        brandLogoImageView.contentMode = .scaleToFill
        brandLogoImageView.clipsToBounds = true
        brandLogoImageView.backgroundColor = .clear
        brandLogoImageView.layer.cornerRadius = 14
        brandLogoImageView.layer.cornerCurve = .continuous
        if brandLogoImageView.superview !== brandTileLabel {
            brandTileLabel.addSubview(brandLogoImageView)
            NSLayoutConstraint.activate([
                brandLogoImageView.topAnchor.constraint(equalTo: brandTileLabel.topAnchor, constant: 5),
                brandLogoImageView.leadingAnchor.constraint(equalTo: brandTileLabel.leadingAnchor, constant: 5),
                brandLogoImageView.trailingAnchor.constraint(equalTo: brandTileLabel.trailingAnchor, constant: -5),
                brandLogoImageView.bottomAnchor.constraint(equalTo: brandTileLabel.bottomAnchor, constant: -5)
            ])
        }
    }

    /// Single meta card: address + hours separated by one divider line (no gap / nested boxes).
    func configureMetaCardLayout() {
        guard let locationRow = addressLabel.superview,
              let hoursRow = hoursLabel.superview,
              let meta = metaCardView else { return }

        meta.backgroundColor = AppPalette.detailCardFill
        meta.layer.cornerRadius = Metric.cardRadius
        meta.layer.cornerCurve = .continuous
        meta.layer.borderWidth = 1
        meta.layer.borderColor = AppPalette.detailCardBorder.cgColor
        meta.clipsToBounds = true

        for row in [locationRow, hoursRow] {
            row.backgroundColor = .clear
            row.layer.borderWidth = 0
            row.layer.cornerRadius = 0
            row.clipsToBounds = false
        }

        // Thin divider only — no extra spacing between address and hours.
        if let divider = meta.subviews.first(where: { $0 !== locationRow && $0 !== hoursRow }) {
            divider.backgroundColor = AppPalette.detailCardBorder
            divider.constraints.filter { $0.firstAttribute == .height }.forEach { $0.constant = 1 }
        }

        // Keep Directions pinned; address fills remaining width and grows vertically.
        if let trailing = locationRow.constraints.first(where: {
            ($0.firstItem as? UIView) === addressLabel
                && $0.firstAttribute == .trailing
                && ($0.secondItem as? UIView) === directionsButton
        }) {
            trailing.isActive = false
            addressLabel.trailingAnchor.constraint(
                equalTo: directionsButton.leadingAnchor,
                constant: -10
            ).isActive = true
        }

        locationRow.constraints.filter {
            $0.firstAttribute == .height && $0.relation == .greaterThanOrEqual
        }.forEach { $0.constant = 56 }

        // Top/bottom padding so multi-line address doesn't clip.
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(greaterThanOrEqualTo: locationRow.topAnchor, constant: 12),
            locationRow.bottomAnchor.constraint(greaterThanOrEqualTo: addressLabel.bottomAnchor, constant: 12)
        ])

        configureHoursDropdown(in: hoursRow)
    }

    func configureHoursDropdown(in hoursRow: UIView) {
        guard !didSetupHoursDropdown else { return }
        didSetupHoursDropdown = true

        let imageViews = hoursRow.subviews.compactMap { $0 as? UIImageView }
        let clockView = imageViews.first
        hoursChevronImageView = imageViews.count > 1 ? imageViews[1] : imageViews.last

        // Larger, bolder dropdown chevron.
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 15, weight: .bold)
        hoursChevronImageView?.image = UIImage(systemName: "chevron.down", withConfiguration: chevronConfig)
        hoursChevronImageView?.tintColor = AppPalette.gold
        hoursChevronImageView?.contentMode = .scaleAspectFit
        hoursChevronImageView?.constraints.forEach { constraint in
            if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
                constraint.constant = 18
            }
        }

        // Header stays at the top; clock + chevron track the summary label.
        hoursRow.constraints.forEach { constraint in
            let involvesHoursLabel = (constraint.firstItem as? UIView) === hoursLabel
                || (constraint.secondItem as? UIView) === hoursLabel
            let involvesClock = (constraint.firstItem as? UIView) === clockView
                || (constraint.secondItem as? UIView) === clockView
            let involvesChevron = (constraint.firstItem as? UIView) === hoursChevronImageView
                || (constraint.secondItem as? UIView) === hoursChevronImageView

            if involvesHoursLabel && (constraint.firstAttribute == .centerY || constraint.secondAttribute == .centerY) {
                constraint.isActive = false
            }
            if involvesHoursLabel && (constraint.firstAttribute == .bottom || constraint.secondAttribute == .bottom) {
                constraint.isActive = false
            }
            if involvesClock && (constraint.firstAttribute == .centerY || constraint.secondAttribute == .centerY) {
                constraint.isActive = false
            }
            if involvesChevron && (constraint.firstAttribute == .centerY || constraint.secondAttribute == .centerY) {
                constraint.isActive = false
            }
            if constraint.firstAttribute == .height && constraint.relation == .greaterThanOrEqual {
                constraint.isActive = false
            }
        }

        hoursWeekdayLabel.translatesAutoresizingMaskIntoConstraints = false
        hoursWeekdayLabel.numberOfLines = 0
        hoursWeekdayLabel.lineBreakMode = .byWordWrapping
        hoursWeekdayLabel.font = UIFont.systemFont(ofSize: 13.5, weight: .regular)
        hoursWeekdayLabel.textColor = AppPalette.secondaryText
        hoursWeekdayLabel.isHidden = true
        hoursWeekdayLabel.alpha = 0
        hoursRow.insertSubview(hoursWeekdayLabel, at: 0)

        // Keep the hit target above the text for taps.
        if let hitButton = hoursRow.subviews.compactMap({ $0 as? UIButton }).first {
            hoursRow.bringSubviewToFront(hitButton)
        }

        let collapsedBottom = hoursLabel.bottomAnchor.constraint(equalTo: hoursRow.bottomAnchor, constant: -14)
        let expandedBottom = hoursWeekdayLabel.bottomAnchor.constraint(equalTo: hoursRow.bottomAnchor, constant: -14)
        hoursCollapsedBottomConstraint = collapsedBottom
        hoursExpandedBottomConstraint = expandedBottom
        expandedBottom.isActive = false

        var constraints: [NSLayoutConstraint] = [
            hoursLabel.topAnchor.constraint(equalTo: hoursRow.topAnchor, constant: 14),
            hoursWeekdayLabel.topAnchor.constraint(equalTo: hoursLabel.bottomAnchor, constant: 10),
            hoursWeekdayLabel.leadingAnchor.constraint(equalTo: hoursLabel.leadingAnchor),
            collapsedBottom
        ]

        if let chevron = hoursChevronImageView {
            constraints.append(contentsOf: [
                hoursWeekdayLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
                chevron.centerYAnchor.constraint(equalTo: hoursLabel.centerYAnchor)
            ])
        } else {
            constraints.append(
                hoursWeekdayLabel.trailingAnchor.constraint(equalTo: hoursRow.trailingAnchor, constant: -16)
            )
        }

        if let clockView {
            constraints.append(clockView.centerYAnchor.constraint(equalTo: hoursLabel.centerYAnchor))
        }

        NSLayoutConstraint.activate(constraints)
        updateHoursChevron(animated: false)
    }

    func weekdayHoursAttributedText(_ lines: [String]) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 5
        paragraph.paragraphSpacing = 2
        return NSAttributedString(string: lines.joined(separator: "\n"), attributes: [
            .font: UIFont.systemFont(ofSize: 13.5, weight: .regular),
            .foregroundColor: AppPalette.secondaryText,
            .paragraphStyle: paragraph
        ])
    }

    func updateHoursChevron(animated: Bool) {
        let transform = isHoursExpanded
            ? CGAffineTransform(rotationAngle: .pi)
            : .identity
        let changes: () -> Void = {
            self.hoursChevronImageView?.transform = transform
        }
        if animated {
            UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: changes)
        } else {
            changes()
        }
    }

    func setHoursExpanded(_ expanded: Bool, animated: Bool) {
        let lines = detail?.resolvedWeekdayHours ?? []
        guard !lines.isEmpty else {
            isHoursExpanded = false
            hoursWeekdayLabel.isHidden = true
            hoursWeekdayLabel.alpha = 0
            hoursExpandedBottomConstraint?.isActive = false
            hoursCollapsedBottomConstraint?.isActive = true
            updateHoursChevron(animated: false)
            return
        }

        isHoursExpanded = expanded
        hoursWeekdayLabel.attributedText = weekdayHoursAttributedText(lines)
        hoursWeekdayLabel.isHidden = false

        let animations = {
            if expanded {
                self.hoursCollapsedBottomConstraint?.isActive = false
                self.hoursExpandedBottomConstraint?.isActive = true
                self.hoursWeekdayLabel.alpha = 1
            } else {
                self.hoursExpandedBottomConstraint?.isActive = false
                self.hoursCollapsedBottomConstraint?.isActive = true
                self.hoursWeekdayLabel.alpha = 0
            }
            self.updateHoursChevron(animated: false)
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut], animations: animations) { _ in
                if !expanded {
                    self.hoursWeekdayLabel.isHidden = true
                }
            }
        } else {
            animations()
            if !expanded {
                hoursWeekdayLabel.isHidden = true
            }
        }
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

    func styleDirectionsButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "paperplane.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold))
        config.title = L10n.directions
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

    func hideSegmentCollection() {
        segmentCollection.isHidden = true
        segmentCollection.isUserInteractionEnabled = false
        segmentCollectionHeight.constant = 0
        tabContentTopSpacing.constant = 0
    }
}

// MARK: - Binding

private extension VenueDetailViewController {
    func fetchDetail() {
        viewModel.load(businessID: businessID) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let detail):
                self.detail = detail
                self.selectedTab = detail.defaultTab
                self.bind()
            case .failure(let error):
                self.showErrorPopup(error)
            }
        }
    }

    func bind() {
        guard let detail else { return }

        heroImageView.configure(urls: heroURLs(for: detail))

        nameLabel.text = detail.name
        verifiedImageView.isHidden = !detail.isVerified
        subtitleLabel.text = detail.subtitle
        ratingLabel.attributedText = ratingAttributedText(
            value: detail.ratingValueText,
            count: detail.reviewCountText
        )
        brandTileLabel.text = nil
        brandLogoImageView.setBusinessImage(urlString: detail.logoURL)
        updatePhotosButtonTitle(detail.photoCountText)
        addressLabel.text = detail.address
        hoursLabel.text = detail.hoursText
        hoursWeekdayLabel.attributedText = weekdayHoursAttributedText(detail.resolvedWeekdayHours)
        isFavorite = detail.isFavorite
        setHoursExpanded(isHoursExpanded, animated: false)

        selectedTab = detail.defaultTab
        renderTabContent()
        updateFavoriteIcon()
    }

    func updatePhotosButtonTitle(_ title: String) {
        var config = photosButton.configuration
        config?.title = title
        photosButton.configuration = config
        photosButton.accessibilityLabel = title
    }

    func heroURLs(for detail: VenueDetail) -> [URL] {
        let urls = detail.resolvedMediaURLs
        return urls.isEmpty ? VenueDemoPhotos.heroURLs : urls
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
        guard let detail else { return }
        tabContentContainer.subviews.forEach { $0.removeFromSuperview() }

        let content: UIView
        switch selectedTab {
        case .deals:
            content = makeDealsContent()
        case .about:
            content = makePlainContent(title: L10n.about, body: detail.aboutText)
        case .menu:
            content = makePlainContent(title: L10n.menu, body: L10n.menuComingSoon)
        case .vibes:
            content = makePlainContent(title: L10n.vibes, body: L10n.vibesComingSoon)
        case .reviews:
            content = makePlainContent(title: L10n.reviews, body: L10n.reviewsComingSoon)
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
        guard let deal = detail?.deal else {
            return makePlainContent(title: L10n.deals, body: L10n.noDeals)
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
        badge.numberOfLines = 2
        badge.lineBreakMode = .byWordWrapping
        badge.translatesAutoresizingMaskIntoConstraints = false

        let discount = UILabel()
        discount.text = deal.discount
        discount.font = UIFont.systemFont(ofSize: 31, weight: .bold)
        discount.textColor = AppPalette.gold
        discount.numberOfLines = 2
        discount.lineBreakMode = .byWordWrapping
        discount.adjustsFontSizeToFitWidth = true
        discount.minimumScaleFactor = 0.6
        discount.translatesAutoresizingMaskIntoConstraints = false

        let detailLabel = UILabel()
        detailLabel.text = deal.detail
        print("DEAL DETAIL ::", deal.detail)
        detailLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        detailLabel.textColor = AppPalette.primaryText
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byWordWrapping
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
        unlock.setTitle(L10n.unlockDeal, for: .normal)
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
        guard let detail else { return }

        if detail.hasCoordinates,
           let latitude = detail.latitude,
           let longitude = detail.longitude {
            openMaps(
                latitude: latitude,
                longitude: longitude,
                name: detail.name,
                address: detail.address
            )
            return
        }

        // Fallback: search by address when lat/lng are missing.
        let query = detail.address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty,
              let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "http://maps.apple.com/?q=\(encoded)") else {
            presentAlert(title: L10n.directions, message: detail.address)
            return
        }
        UIApplication.shared.open(url)
    }

    func openMaps(latitude: Double, longitude: Double, name: String, address: String) {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name.isEmpty ? address : name
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMaps(launchOptions: options)
    }

    @IBAction func handleHours() {
        let lines = detail?.resolvedWeekdayHours ?? []
        guard !lines.isEmpty else { return }
        setHoursExpanded(!isHoursExpanded, animated: true)
        UISelectionFeedbackGenerator().selectionChanged()
    }

    @IBAction func handleCall() {
        presentAlert(title: L10n.call, message: detail?.phone ?? "")
    }

    @IBAction func handleWebsite() {
        presentAlert(title: L10n.website, message: detail?.website ?? "")
    }

    @IBAction func handleInstagram() {
        presentAlert(title: L10n.instagram, message: "@\(detail?.instagram ?? "")")
    }

    @objc func handlePhotos() {
        let name = detail?.name ?? "Venue"
        let urls = detail?.resolvedMediaURLs ?? []
        let controller = VenuePhotosViewController(
            venueName: name,
            imageURLs: urls.isEmpty ? VenueDemoPhotos.demoURLs : urls
        )
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func handleSoon(_ sender: UIButton) {
        let title = sender.accessibilityLabel ?? sender.configuration?.title ?? L10n.comingSoon
        presentAlert(title: title, message: L10n.comingSoon)
    }

    func presentAlert(title: String, message: String) {
        showAnimatedAlert(title: title, message: message, style: .info)
    }

    /// Brand tile: first word only; long words truncate to 4 characters + ellipsis.
    static func brandTileTitle(from name: String) -> String {
        let firstWord = name
            .split(whereSeparator: \.isWhitespace)
            .first
            .map(String.init)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            ?? ""
        guard !firstWord.isEmpty else { return "" }
        if firstWord.count > 4 {
            return String(firstWord.prefix(4)) + "..."
        }
        return firstWord
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
