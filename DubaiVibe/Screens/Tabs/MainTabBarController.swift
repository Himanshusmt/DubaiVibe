import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        installTabs()
        configureAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        repositionFloatingTabBarIfNeeded()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        repositionFloatingTabBarIfNeeded()
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // Selection re-lays out system tab buttons; re-apply our fixed chip layout.
        (tabBar as? FloatingTabBar)?.refreshItemLayout()
    }
}

private extension MainTabBarController {
    func installTabs() {
        guard
            let controllers = viewControllers,
            controllers.count == 2,
            let home = controllers.first,
            let profile = controllers.last
        else {
            return
        }

        home.tabBarItem = TabDesign.home.makeItem()
        profile.tabBarItem = TabDesign.profile.makeItem()
        viewControllers = [home, profile]
        selectedIndex = 0
    }

    func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()
        appearance.selectionIndicatorTintColor = .clear
        appearance.selectionIndicatorImage = UIImage()

        styleItems(appearance.stackedLayoutAppearance)
        styleItems(appearance.inlineLayoutAppearance)
        styleItems(appearance.compactInlineLayoutAppearance)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .clear
        tabBar.barTintColor = .clear
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.tintColor = AppPalette.tabLabel
        tabBar.unselectedItemTintColor = AppPalette.tabLabel
        tabBar.itemPositioning = .centered
        tabBar.itemWidth = AppMetrics.floatingTabItemWidth
        tabBar.itemSpacing = AppMetrics.floatingTabItemSpacing
        tabBar.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin]
        tabBar.clipsToBounds = false
        tabBar.layer.masksToBounds = false
        if #available(iOS 26.0, *) {
            tabBarMinimizeBehavior = .never
        }
    }

    /// Figma: Inter Medium 11 / #D4D4D4 for both Home and Profile.
    func styleItems(_ layout: UITabBarItemAppearance) {
        let title: [NSAttributedString.Key: Any] = [
            .foregroundColor: AppPalette.tabLabel,
            .font: AppTypography.font(.medium, size: AppMetrics.floatingTabTitleFontSize)
        ]
        layout.normal.titleTextAttributes = title
        layout.selected.titleTextAttributes = title
        // Vertical placement is applied in FloatingTabBar (15pt top / 15pt bottom).
        layout.normal.titlePositionAdjustment = .zero
        layout.selected.titlePositionAdjustment = .zero
    }

    func repositionFloatingTabBarIfNeeded() {
        guard tabBar.superview != nil, !tabBar.isHidden else { return }

        // Hidden off-screen (e.g. hidesBottomBarWhenPushed).
        if tabBar.frame.minY >= view.bounds.height - 1 {
            return
        }

        tabBar.itemPositioning = .centered
        tabBar.itemWidth = AppMetrics.floatingTabItemWidth
        tabBar.itemSpacing = AppMetrics.floatingTabItemSpacing

        let target = AppMetrics.floatingTabChipFrame(in: view)
        if tabBar.frame != target {
            tabBar.frame = target
        }
        // Keep the floating chip above the active screen so glass can sample it.
        view.bringSubviewToFront(tabBar)
        (tabBar as? FloatingTabBar)?.refreshItemLayout()
    }
}

/// Floating 170×80 Home / Profile chip with Liquid Glass, 1pt #494949 border.
final class FloatingTabBar: UITabBar {
    private let chromeView = UIView()
    private let glassView = UIVisualEffectView()
    private let tintOverlay = UIView()
    private let borderLayer = CAShapeLayer()
    private let innerShadowLayer = CAShapeLayer()
    /// Static icon + label drawn by us; the system's own views animate on tap, so they stay hidden.
    private var itemOverlays: [TabItemOverlay] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupChrome()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupChrome()
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        AppMetrics.floatingTabPillSize
    }

    override func layoutSubviews() {
        if let host = superview, frame.minY < host.bounds.height - 1 {
            let target = AppMetrics.floatingTabChipFrame(in: host)
            if frame != target {
                frame = target
            }
        }
        super.layoutSubviews()
        layoutChrome()
        layoutItemContent()
        hideSystemBackgrounds()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let radius = min(AppMetrics.floatingTabCornerRadius, bounds.height / 2)
        let capsule = UIBezierPath(roundedRect: bounds, cornerRadius: radius)
        guard capsule.contains(point) else { return nil }
        return super.hitTest(point, with: event)
    }

    func refreshItemLayout() {
        UIView.performWithoutAnimation {
            setNeedsLayout()
            layoutIfNeeded()
            layoutItemContent()
            hideSystemBackgrounds()
        }
    }

    private func setupChrome() {
        isTranslucent = true
        backgroundImage = UIImage()
        shadowImage = UIImage()
        backgroundColor = .black
        clipsToBounds = false
        layer.masksToBounds = false

        chromeView.isUserInteractionEnabled = false
        chromeView.clipsToBounds = true
        chromeView.backgroundColor = .clear
        insertSubview(chromeView, at: 0)

        glassView.clipsToBounds = true
        chromeView.addSubview(glassView)

        tintOverlay.isUserInteractionEnabled = false
        chromeView.addSubview(tintOverlay)

        if #available(iOS 26.0, *) {
            let glass = UIGlassEffect(style: .regular)
            glass.isInteractive = true
            // Light tint — heavy fill makes Liquid Glass look like a solid pill.
            glass.tintColor = UIColor(hex: 0x181717, alpha: 0.28)
            glassView.effect = glass
            tintOverlay.isHidden = true
        } else {
            glassView.effect = UIBlurEffect(style: .systemChromeMaterialDark)
            tintOverlay.backgroundColor = UIColor(hex: 0x181717, alpha: 0.35)
            tintOverlay.isHidden = false
        }

        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = AppPalette.tabBarBorder.cgColor
        borderLayer.lineWidth = 1
        layer.addSublayer(borderLayer)

        innerShadowLayer.fillRule = .evenOdd
        innerShadowLayer.fillColor = UIColor.black.cgColor
        innerShadowLayer.shadowColor = UIColor.black.cgColor
        innerShadowLayer.shadowOffset = .zero
        innerShadowLayer.shadowOpacity = 0.18
        innerShadowLayer.shadowRadius = 10
        chromeView.layer.addSublayer(innerShadowLayer)
    }

    private func layoutChrome() {
        sendSubviewToBack(chromeView)
        chromeView.frame = bounds
        glassView.frame = chromeView.bounds
        tintOverlay.frame = chromeView.bounds

        let radius = min(AppMetrics.floatingTabCornerRadius, bounds.height / 2)
        chromeView.layer.cornerRadius = radius
        chromeView.layer.cornerCurve = .continuous
        glassView.layer.cornerRadius = radius
        glassView.layer.cornerCurve = .continuous
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous

        let inset = borderLayer.lineWidth / 2
        borderLayer.frame = bounds
        borderLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: inset, dy: inset),
            cornerRadius: max(radius - inset, 0)
        ).cgPath

        innerShadowLayer.frame = chromeView.bounds
        let cutout = UIBezierPath(roundedRect: chromeView.bounds, cornerRadius: radius)
        let outer = UIBezierPath(
            roundedRect: chromeView.bounds.insetBy(dx: -27, dy: -27),
            cornerRadius: radius
        )
        outer.append(cutout)
        innerShadowLayer.path = outer.cgPath
        innerShadowLayer.shadowPath = cutout.cgPath
    }

    /// Icon ~15pt from top, title ~15pt from bottom, then tighten icon↔title by 2pt.
    private func layoutItemContent() {
        let buttons = subviews
            .compactMap { $0 as? UIControl }
            .sorted { $0.frame.minX < $1.frame.minX }
        let barItems = items ?? []
        guard !buttons.isEmpty, buttons.count == barItems.count else { return }

        syncOverlays(count: buttons.count)

        let inset = AppMetrics.floatingTabContentInset
        let tighten = AppMetrics.floatingTabIconTitleTighten
        let iconSize = AppMetrics.floatingTabIconSize
        let titleHeight = ceil(AppTypography.font(.medium, size: AppMetrics.floatingTabTitleFontSize).lineHeight)
        let iconY = inset + (tighten / 2)
        let titleBottom = inset + (tighten / 2)

        UIView.performWithoutAnimation {
            for (index, button) in buttons.enumerated() {
                hideSystemContent(in: button)

                let overlay = itemOverlays[index]
                overlay.frame = button.frame
                overlay.iconView.image = barItems[index].image
                overlay.titleLabel.text = barItems[index].title

                overlay.iconView.frame = CGRect(
                    x: (overlay.bounds.width - iconSize) / 2,
                    y: iconY,
                    width: iconSize,
                    height: iconSize
                )

                let titleSize = overlay.titleLabel.sizeThatFits(
                    CGSize(width: overlay.bounds.width, height: titleHeight)
                )
                let titleWidth = min(overlay.bounds.width, ceil(titleSize.width))
                overlay.titleLabel.frame = CGRect(
                    x: (overlay.bounds.width - titleWidth) / 2,
                    y: overlay.bounds.height - titleBottom - titleHeight,
                    width: titleWidth,
                    height: titleHeight
                )

                bringSubviewToFront(overlay)
            }
        }
    }

    private func syncOverlays(count: Int) {
        while itemOverlays.count < count {
            let overlay = TabItemOverlay()
            addSubview(overlay)
            itemOverlays.append(overlay)
        }
        while itemOverlays.count > count {
            itemOverlays.removeLast().removeFromSuperview()
        }
    }

    /// Blank out the system icon/label so its selection animation is invisible.
    private func hideSystemContent(in root: UIView) {
        for subview in root.subviews {
            if subview is UIImageView || subview is UILabel {
                subview.alpha = 0
            }
            hideSystemContent(in: subview)
        }
    }

    private func hideSystemBackgrounds() {
        for subview in subviews where subview !== chromeView && !(subview is TabItemOverlay) {
            let name = String(describing: type(of: subview))
            if subview is UIVisualEffectView
                || name.contains("BarBackground")
                || name.contains("Platter")
                || name.contains("Glass")
                || name.contains("Selection") {
                subview.isHidden = true
                subview.alpha = 0
            }
        }
    }
}

/// Non-interactive icon + label pair; taps fall through to the system tab button beneath.
private final class TabItemOverlay: UIView {
    let iconView = UIImageView()
    let titleLabel = UILabel()

    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        iconView.contentMode = .scaleAspectFit
        titleLabel.font = AppTypography.font(.medium, size: AppMetrics.floatingTabTitleFontSize)
        titleLabel.textColor = AppPalette.tabLabel
        titleLabel.textAlignment = .center
        addSubview(iconView)
        addSubview(titleLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private enum TabDesign {
    case home
    case profile

    var title: String {
        switch self {
        case .home: return "Home"
        case .profile: return "Profile"
        }
    }

    func makeItem() -> UITabBarItem {
        let icon = tabIcon()
        let item = UITabBarItem(title: title, image: icon, selectedImage: icon)
        item.imageInsets = .zero
        item.titlePositionAdjustment = .zero
        return item
    }

    private var assetName: String {
        switch self {
        case .home: return "TabHome"
        case .profile: return "TabProfile"
        }
    }

    /// Figma icons sit in a 24pt box; keep the exported glyph centered at its native size.
    private func tabIcon() -> UIImage? {
        guard let image = UIImage(named: assetName) else { return nil }
        let canvas = AppMetrics.floatingTabIconSize
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        let size = CGSize(width: canvas, height: canvas)
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            let origin = CGPoint(
                x: (canvas - image.size.width) / 2,
                y: (canvas - image.size.height) / 2
            )
            image.draw(in: CGRect(origin: origin, size: image.size))
        }.withRenderingMode(.alwaysOriginal)
    }
}
