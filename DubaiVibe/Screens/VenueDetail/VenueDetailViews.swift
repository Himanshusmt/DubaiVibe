import SDWebImage
import UIKit

/// Diagonal gold fill used by chips, deal CTAs, and offer panels.
final class GoldGradientView: UIView {
    enum Kind {
        case cta
        case dealPanel
        case heroFade
    }

    var kind: Kind = .cta {
        didSet { applyKind() }
    }

    private let gradient = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        clipsToBounds = true
        layer.insertSublayer(gradient, at: 0)
        applyKind()
    }

    private func applyKind() {
        switch kind {
        case .cta:
            // Figma View Deal: linear-gradient(135.44deg, #F3CE85 0%, #D8A04D 100%)
            gradient.colors = [
                AppPalette.goldGradientTop.cgColor,
                AppPalette.goldGradientBottom.cgColor
            ]
            gradient.locations = [0, 1]
            gradient.startPoint = CGPoint(x: 0, y: 0)
            gradient.endPoint = CGPoint(x: 1, y: 1)
        case .dealPanel:
            // Yellow wash only top 17%; black covers remaining 83%.
            // #FFA903 @17% opacity → #0B0B0C
            gradient.colors = [
                AppPalette.dealGradientWash.cgColor.copy(alpha: 0.1) ?? 0.1,
                AppPalette.dealFill.cgColor.copy(alpha: 0.15) ?? 0.15
            ]
            gradient.locations = [0, 0.37]
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        case .heroFade:
            gradient.colors = [
                UIColor.black.withAlphaComponent(0.30).cgColor,
                UIColor.black.withAlphaComponent(0.20).cgColor,
                UIColor.black.withAlphaComponent(0.80).cgColor
            ]
            gradient.locations = [0, 0.5, 1]
            gradient.startPoint = CGPoint(x: 0.5, y: 0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1)
        }
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        gradient.cornerRadius = layer.cornerRadius
        gradient.cornerCurve = layer.cornerCurve
        gradient.masksToBounds = true
    }
}

/// 1pt inner gradient stroke used by the exclusive deal panel.
final class GradientBorderView: UIView {
    var lineWidth: CGFloat = 1 {
        didSet { setNeedsLayout() }
    }

    private let gradient = CAGradientLayer()
    private let maskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        isUserInteractionEnabled = false
        backgroundColor = .clear
        // Figma Borders → primary color: #FCE19B → #E2A645 → #B87B22
        gradient.colors = [
            AppPalette.dealBorderGradientTop.cgColor,
            AppPalette.dealBorderGradientMid.cgColor,
            AppPalette.dealBorderGradientBottom.cgColor
        ]
        gradient.locations = [0, 0.5, 1]
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        maskLayer.fillRule = .evenOdd
        gradient.mask = maskLayer
        layer.addSublayer(gradient)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
        let radius = layer.cornerRadius
        let outer = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        let insetBounds = bounds.insetBy(dx: lineWidth, dy: lineWidth)
        let innerRadius = max(0, radius - lineWidth)
        let inner = UIBezierPath(roundedRect: insetBounds, cornerRadius: innerRadius)
        outer.append(inner)
        maskLayer.path = outer.cgPath
    }
}

/// Gold gradient CTA used by the deal card.
final class GoldGradientButton: UIButton {
    /// Unlock Deal: linear-gradient(97.73deg, #FAD77A 0%, #E3A338 50%, #B87B14 100%).
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        configuration = nil
        backgroundColor = .clear
        tintColor = AppPalette.onGold
        setTitleColor(AppPalette.onGold, for: .normal)
        titleLabel?.font = AppTypography.font(.bold, size: 16)
        layer.cornerRadius = 12
        layer.cornerCurve = .continuous
        clipsToBounds = true

        gradientLayer.colors = [
            AppPalette.unlockDealGradientStart.cgColor,
            AppPalette.unlockDealGradientMid.cgColor,
            AppPalette.unlockDealGradientEnd.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        // CSS 97.73deg: 0° is up, clockwise. Maps to a near-horizontal left → right sweep.
        let radians = (97.73 - 90) * CGFloat.pi / 180
        let dx = cos(radians)
        let dy = sin(radians)
        gradientLayer.startPoint = CGPoint(x: 0.5 - dx / 2, y: 0.5 - dy / 2)
        gradientLayer.endPoint = CGPoint(x: 0.5 + dx / 2, y: 0.5 + dy / 2)
        gradientLayer.cornerRadius = 12
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if configuration != nil {
            let current = title(for: .normal)
            let color = titleColor(for: .normal)
            configuration = nil
            if let current { setTitle(current, for: .normal) }
            if let color { setTitleColor(color, for: .normal) }
        }
        backgroundColor = .clear
        for subview in subviews where subview !== titleLabel && subview !== imageView {
            subview.backgroundColor = .clear
            subview.isOpaque = false
        }
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
        gradientLayer.cornerCurve = layer.cornerCurve
        layer.insertSublayer(gradientLayer, at: 0)
        if let titleLabel { bringSubviewToFront(titleLabel) }
        if let imageView { bringSubviewToFront(imageView) }
    }
}

/// Paging hero carousel with auto-scroll and a bottom fade so overlay pills stay readable.
final class HeroImageView: UIImageView {
    private enum Metric {
        static let autoScrollInterval: TimeInterval = 1
    }

    private let fadeView = UIView()
    private let fade = CAGradientLayer()
    private let pageControl = UIPageControl()
    private var imageURLs: [URL] = []
    private var currentPage = 0
    private var laidOutSize: CGSize = .zero
    private var autoScrollTimer: Timer?

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.contentInsetAdjustmentBehavior = .never
        view.bounces = false
        view.register(VenueHeroImageCell.self, forCellWithReuseIdentifier: VenueHeroImageCell.reuseIdentifier)
        view.dataSource = self
        view.delegate = self
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        autoScrollTimer?.invalidate()
    }

    func configure(urls: [URL]) {
        imageURLs = urls
        currentPage = 0
        pageControl.numberOfPages = urls.count
        pageControl.currentPage = 0
        pageControl.isHidden = true
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
        if !urls.isEmpty {
            SDWebImagePrefetcher.shared.prefetchURLs(urls)
        }
        startAutoScroll()
    }

    func startAutoScroll() {
        stopAutoScroll()
        guard imageURLs.count > 1, window != nil else { return }
        let timer = Timer(timeInterval: Metric.autoScrollInterval, repeats: true) { [weak self] _ in
            self?.advancePage()
        }
        timer.tolerance = 0.05
        RunLoop.main.add(timer, forMode: .common)
        autoScrollTimer = timer
    }

    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopAutoScroll()
        } else {
            startAutoScroll()
        }
    }

    private func setup() {
        contentMode = .scaleAspectFill
        clipsToBounds = true
        // UIImageView opts out of touch delivery, but the hero hosts the pager.
        isUserInteractionEnabled = true

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)

        fadeView.isUserInteractionEnabled = false
        fadeView.translatesAutoresizingMaskIntoConstraints = false
        fade.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.30).cgColor,
            UIColor.black.withAlphaComponent(0.62).cgColor
        ]
        fade.locations = [0.35, 0.72, 1]
        fadeView.layer.addSublayer(fade)
        addSubview(fadeView)

        pageControl.hidesForSinglePage = true
        pageControl.isHidden = true
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.38)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.addTarget(self, action: #selector(handlePageControlChanged), for: .valueChanged)
        addSubview(pageControl)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            fadeView.topAnchor.constraint(equalTo: topAnchor),
            fadeView.leadingAnchor.constraint(equalTo: leadingAnchor),
            fadeView.trailingAnchor.constraint(equalTo: trailingAnchor),
            fadeView.bottomAnchor.constraint(equalTo: bottomAnchor),

            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        fade.frame = fadeView.bounds
        let size = collectionView.bounds.size
        guard size.width > 1, size.height > 1, size != laidOutSize else { return }
        laidOutSize = size
        collectionView.collectionViewLayout.invalidateLayout()
        let offset = CGFloat(currentPage) * size.width
        collectionView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
    }

    private func advancePage() {
        guard imageURLs.count > 1,
              collectionView.bounds.width > 1,
              !collectionView.isDragging,
              !collectionView.isDecelerating else { return }
        let next = (currentPage + 1) % imageURLs.count
        let wrapsToStart = next == 0 && currentPage == imageURLs.count - 1
        scrollToPage(next, animated: !wrapsToStart)
    }

    private func scrollToPage(_ page: Int, animated: Bool) {
        let indexPath = IndexPath(item: page, section: 0)
        guard imageURLs.indices.contains(page),
              collectionView.numberOfItems(inSection: 0) > page else { return }
        currentPage = page
        pageControl.currentPage = page
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
    }

    private func syncPageFromOffset() {
        guard collectionView.bounds.width > 0, !imageURLs.isEmpty else { return }
        let page = Int(round(collectionView.contentOffset.x / collectionView.bounds.width))
        currentPage = min(max(page, 0), imageURLs.count - 1)
        pageControl.currentPage = currentPage
    }

    @objc private func handlePageControlChanged() {
        scrollToPage(pageControl.currentPage, animated: true)
        startAutoScroll()
    }
}

extension HeroImageView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imageURLs.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: VenueHeroImageCell.reuseIdentifier,
            for: indexPath
        ) as? VenueHeroImageCell else {
            return UICollectionViewCell()
        }
        cell.configure(url: imageURLs[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = collectionView.bounds.size
        return CGSize(width: max(size.width, 1), height: max(size.height, 1))
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopAutoScroll()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            syncPageFromOffset()
            startAutoScroll()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        syncPageFromOffset()
        startAutoScroll()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        syncPageFromOffset()
    }
}

private final class VenueHeroImageCell: UICollectionViewCell {
    static let reuseIdentifier = "VenueHeroImageCell"

    private let imageView = UIImageView()
    private let spinner = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.backgroundColor = AppPalette.surface

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)

        spinner.color = AppPalette.gold
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(spinner)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
        imageView.image = nil
        spinner.stopAnimating()
    }

    func configure(url: URL) {
        spinner.startAnimating()
        imageView.sd_setImage(
            with: url,
            placeholderImage: nil,
            options: [.retryFailed, .highPriority, .scaleDownLargeImages]
        ) { [weak self] _, _, _, _ in
            self?.spinner.stopAnimating()
        }
    }
}

/// Glyphs that don't ship with SF Symbols, drawn once and cached.
enum BrandGlyphs {
    static let instagram: UIImage = {
        let size = CGSize(width: 24, height: 24)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.9)

            let frame = CGRect(x: 2.5, y: 2.5, width: 19, height: 19)
            context.addPath(UIBezierPath(roundedRect: frame, cornerRadius: 6).cgPath)
            context.strokePath()

            context.addEllipse(in: CGRect(x: 8, y: 8, width: 8, height: 8))
            context.strokePath()

            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(x: 16.2, y: 6.1, width: 2.4, height: 2.4))
        }.withRenderingMode(.alwaysTemplate)
    }()

    static let shareNodes: UIImage = {
        let size = CGSize(width: 24, height: 24)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.7)

            let right = CGPoint(x: 17.5, y: 5.5)
            let left = CGPoint(x: 6.5, y: 12)
            let bottom = CGPoint(x: 17.5, y: 18.5)

            context.move(to: left)
            context.addLine(to: right)
            context.move(to: left)
            context.addLine(to: bottom)
            context.strokePath()

            for point in [right, left, bottom] {
                let dot = CGRect(x: point.x - 3.1, y: point.y - 3.1, width: 6.2, height: 6.2)
                context.addEllipse(in: dot)
            }
            context.strokePath()
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Deal-banner crown: a pointed centre shield flanked by two thin arms over a base band.
    static let crown: UIImage = {
        let size = CGSize(width: 28, height: 28)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext

            let shield = UIBezierPath()
            shield.move(to: CGPoint(x: 14, y: 0.6))
            shield.addCurve(
                to: CGPoint(x: 20.2, y: 9.0),
                controlPoint1: CGPoint(x: 15.6, y: 3.4),
                controlPoint2: CGPoint(x: 18.0, y: 6.4)
            )
            shield.addLine(to: CGPoint(x: 19.6, y: 20.8))
            shield.addLine(to: CGPoint(x: 8.4, y: 20.8))
            shield.addLine(to: CGPoint(x: 7.8, y: 9.0))
            shield.addCurve(
                to: CGPoint(x: 14, y: 0.6),
                controlPoint1: CGPoint(x: 10.0, y: 6.4),
                controlPoint2: CGPoint(x: 12.4, y: 3.4)
            )
            shield.fill()

            context.setLineWidth(2.3)
            context.setLineCap(.round)
            for direction in [CGFloat(-1), 1] {
                context.move(to: CGPoint(x: 14 + direction * 10.6, y: 8.2))
                context.addLine(to: CGPoint(x: 14 + direction * 7.0, y: 20.8))
            }
            context.strokePath()

            UIBezierPath(
                roundedRect: CGRect(x: 4.8, y: 22.6, width: 18.4, height: 3.0),
                cornerRadius: 0.8
            ).fill()

            context.setBlendMode(.clear)
            let notch = UIBezierPath()
            notch.move(to: CGPoint(x: 12.2, y: 22.4))
            notch.addLine(to: CGPoint(x: 15.8, y: 22.4))
            notch.addLine(to: CGPoint(x: 14, y: 24.4))
            notch.close()
            notch.fill()
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Solid teardrop map marker used by the city picker.
    static let mapPin: UIImage = {
        let size = CGSize(width: 20, height: 24)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let pin = UIBezierPath()
            pin.move(to: CGPoint(x: 10, y: 23))
            pin.addCurve(
                to: CGPoint(x: 1, y: 9.4),
                controlPoint1: CGPoint(x: 5.4, y: 16.6),
                controlPoint2: CGPoint(x: 1, y: 12.6)
            )
            pin.addArc(
                withCenter: CGPoint(x: 10, y: 9.4),
                radius: 9,
                startAngle: .pi,
                endAngle: 0,
                clockwise: true
            )
            pin.addCurve(
                to: CGPoint(x: 10, y: 23),
                controlPoint1: CGPoint(x: 19, y: 12.6),
                controlPoint2: CGPoint(x: 14.6, y: 16.6)
            )
            pin.fill()

            ctx.cgContext.setBlendMode(.clear)
            ctx.cgContext.fillEllipse(in: CGRect(x: 6.6, y: 6, width: 6.8, height: 6.8))
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Martini glass for the bars chip.
    static let martini: UIImage = {
        let size = CGSize(width: 22, height: 22)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.6)
            context.setLineJoin(.round)
            context.setLineCap(.round)

            context.move(to: CGPoint(x: 2.4, y: 3.4))
            context.addLine(to: CGPoint(x: 19.6, y: 3.4))
            context.addLine(to: CGPoint(x: 11, y: 12.4))
            context.closePath()
            context.strokePath()

            context.move(to: CGPoint(x: 11, y: 12.4))
            context.addLine(to: CGPoint(x: 11, y: 18.4))
            context.move(to: CGPoint(x: 5.6, y: 18.8))
            context.addLine(to: CGPoint(x: 16.4, y: 18.8))
            context.strokePath()
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Mirror ball for the nightlife chip.
    static let discoBall: UIImage = {
        let size = CGSize(width: 22, height: 22)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            let ball = CGRect(x: 3, y: 5, width: 16, height: 16)

            context.move(to: CGPoint(x: 11, y: 1.4))
            context.addLine(to: CGPoint(x: 11, y: 5))
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.4)
            context.strokePath()

            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: ball)

            // Punch the lattice out of the sphere so the fill reads as facets.
            context.setBlendMode(.clear)
            context.setLineWidth(1)
            context.saveGState()
            context.addEllipse(in: ball)
            context.clip()
            for row in stride(from: ball.minY + 3.2, to: ball.maxY, by: 3.2) {
                context.move(to: CGPoint(x: ball.minX, y: row))
                context.addLine(to: CGPoint(x: ball.maxX, y: row))
            }
            context.strokePath()
            for inset in stride(from: CGFloat(0), through: 6, by: 3) {
                let oval = ball.insetBy(dx: inset, dy: 0)
                context.addEllipse(in: oval)
            }
            context.strokePath()
            context.restoreGState()
        }.withRenderingMode(.alwaysTemplate)
    }()

    /// Steaming mug for the cafés chip.
    static let mug: UIImage = {
        let size = CGSize(width: 22, height: 22)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.3)
            context.setLineCap(.round)

            context.move(to: CGPoint(x: 8.2, y: 5.4))
            context.addCurve(
                to: CGPoint(x: 8.2, y: 1.8),
                control1: CGPoint(x: 6.4, y: 3.8),
                control2: CGPoint(x: 10, y: 3.4)
            )
            context.move(to: CGPoint(x: 12.2, y: 5.4))
            context.addCurve(
                to: CGPoint(x: 12.2, y: 1.8),
                control1: CGPoint(x: 10.4, y: 3.8),
                control2: CGPoint(x: 14, y: 3.4)
            )
            context.strokePath()

            let cup = UIBezierPath(
                roundedRect: CGRect(x: 2.4, y: 8, width: 12.4, height: 10.6),
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 3.4, height: 3.4)
            )
            cup.fill()

            context.setLineWidth(1.7)
            context.addArc(
                center: CGPoint(x: 15.2, y: 11.8),
                radius: 3.4,
                startAngle: -.pi / 2,
                endAngle: .pi / 2,
                clockwise: false
            )
            context.strokePath()
        }.withRenderingMode(.alwaysTemplate)
    }()
}
