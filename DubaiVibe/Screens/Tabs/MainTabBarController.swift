import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        installTabs()
        configureAppearance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stripGlassEffects()
    }
}

private extension MainTabBarController {
    /// Design order: Online | Profile | Dashboard | Social | Deals, with Dashboard in the middle.
    func installTabs() {
        // Keep ProfileViewController linked so storyboard can resolve the custom class.
        _ = ProfileViewController.self

        guard
            let controllers = viewControllers,
            controllers.count == 2,
            let dashboard = controllers.first,
            let profile = controllers.last
        else {
            return
        }

        dashboard.tabBarItem = TabDesign.dashboard.makeItem()
        profile.tabBarItem = TabDesign.profile.makeItem()

        viewControllers = [
            SoonViewController(design: .online),
            profile,
            dashboard,
            SoonViewController(design: .social),
            SoonViewController(design: .deals)
        ]
        selectedIndex = 2
    }

    func configureAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppPalette.background
        appearance.backgroundEffect = nil
        appearance.shadowColor = AppPalette.separator
        appearance.shadowImage = UIImage()
        appearance.selectionIndicatorTintColor = .clear
        appearance.selectionIndicatorImage = UIImage()

        styleItems(appearance.stackedLayoutAppearance)
        styleItems(appearance.inlineLayoutAppearance)
        styleItems(appearance.compactInlineLayoutAppearance)

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.isTranslucent = false
        tabBar.backgroundColor = AppPalette.background
        tabBar.barTintColor = AppPalette.background
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.clipsToBounds = true
    }

    /// Icons stay gold in both states; only the label picks up the selection.
    func styleItems(_ layout: UITabBarItemAppearance) {
        layout.normal.titleTextAttributes = [
            .foregroundColor: AppPalette.primaryText,
            .font: UIFont.systemFont(ofSize: 11, weight: .regular)
        ]
        layout.selected.titleTextAttributes = [
            .foregroundColor: AppPalette.gold,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium)
        ]
        layout.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -1)
        layout.selected.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -1)
    }

    func stripGlassEffects() {
        for subview in tabBar.subviews {
            let name = String(describing: type(of: subview))
            if subview is UIVisualEffectView
                || name.contains("Glass")
                || name.contains("Selection")
                || name.contains("VisualEffect") {
                subview.isHidden = true
                subview.alpha = 0
            }
        }
    }
}

/// The five tabs from the design, each with its own gold glyph and optional status dot.
enum TabDesign {
    case online
    case profile
    case dashboard
    case social
    case deals

    var title: String {
        switch self {
        case .online: return "Online"
        case .profile: return "Profile"
        case .dashboard: return "Dashboard"
        case .social: return "Social"
        case .deals: return "Deals"
        }
    }

    func makeItem() -> UITabBarItem {
        let item = UITabBarItem(title: title, image: icon, selectedImage: icon)
        item.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: -2, right: 0)
        return item
    }

    /// Rendered in gold up front so the dots keep their own colour in both states.
    private var icon: UIImage {
        TabGlyphs.image(for: self)
    }
}

enum TabGlyphs {
    static func image(for design: TabDesign) -> UIImage {
        let size = CGSize(width: 28, height: 26)
        return UIGraphicsImageRenderer(size: size).image { ctx in
            let context = ctx.cgContext
            context.setStrokeColor(AppPalette.gold.cgColor)
            context.setFillColor(AppPalette.gold.cgColor)
            context.setLineWidth(1.7)
            context.setLineCap(.round)
            context.setLineJoin(.round)

            switch design {
            case .online:
                drawPerson(context, centerX: 13, scale: 1)
                dot(context, at: CGPoint(x: 21.4, y: 6.6), color: AppPalette.onlineGreen)
            case .profile:
                drawPerson(context, centerX: 14, scale: 1)
            case .dashboard:
                drawBars(context)
            case .social:
                drawPerson(context, centerX: 18.4, scale: 0.62)
                // Knock a gap out of the back figure so the front one reads as in front.
                context.setBlendMode(.clear)
                context.setLineWidth(4.4)
                drawPerson(context, centerX: 11.4, scale: 0.94)
                context.setBlendMode(.normal)
                context.setLineWidth(1.7)
                drawPerson(context, centerX: 11.4, scale: 0.94)
                dot(context, at: CGPoint(x: 23.2, y: 5.2), color: AppPalette.badgeRed)
            case .deals:
                drawTag(context)
            }
        }.withRenderingMode(.alwaysOriginal)
    }

    private static func drawPerson(_ context: CGContext, centerX: CGFloat, scale: CGFloat) {
        let headRadius = 4.2 * scale
        let headCenter = CGPoint(x: centerX, y: 7.4 + (1 - scale) * 2)
        context.addEllipse(in: CGRect(
            x: headCenter.x - headRadius,
            y: headCenter.y - headRadius,
            width: headRadius * 2,
            height: headRadius * 2
        ))
        context.strokePath()

        let width = 15.4 * scale
        let shoulders = UIBezierPath()
        shoulders.move(to: CGPoint(x: centerX - width / 2, y: 21.4))
        shoulders.addCurve(
            to: CGPoint(x: centerX + width / 2, y: 21.4),
            controlPoint1: CGPoint(x: centerX - width / 2, y: 14.4),
            controlPoint2: CGPoint(x: centerX + width / 2, y: 14.4)
        )
        context.addPath(shoulders.cgPath)
        context.strokePath()
    }

    private static func drawBars(_ context: CGContext) {
        let heights: [CGFloat] = [9, 16, 12.5]
        for (index, height) in heights.enumerated() {
            let x = 7.5 + CGFloat(index) * 6.5
            let bar = UIBezierPath(
                roundedRect: CGRect(x: x, y: 21 - height, width: 4.4, height: height),
                cornerRadius: 1.4
            )
            bar.fill()
        }
    }

    private static func drawTag(_ context: CGContext) {
        let tag = UIBezierPath()
        tag.move(to: CGPoint(x: 15.6, y: 4.6))
        tag.addLine(to: CGPoint(x: 23.4, y: 4.6))
        tag.addLine(to: CGPoint(x: 23.4, y: 12.4))
        tag.addLine(to: CGPoint(x: 13.2, y: 21.6))
        tag.addLine(to: CGPoint(x: 5, y: 13.2))
        tag.close()
        tag.lineWidth = 1.7
        tag.lineJoinStyle = .round
        tag.stroke()
    }

    private static func dot(_ context: CGContext, at center: CGPoint, color: UIColor) {
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: center.x - 3, y: center.y - 3, width: 6, height: 6))
        context.setFillColor(AppPalette.gold.cgColor)
    }
}

/// Placeholder screen for the tabs that aren't built yet.
private final class SoonViewController: UIViewController {
    private let design: TabDesign

    init(design: TabDesign) {
        self.design = design
        super.init(nibName: nil, bundle: nil)
        tabBarItem = design.makeItem()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppPalette.background

        let icon = UIImageView(image: TabGlyphs.image(for: design))
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = design.title
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = AppPalette.primaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(icon)
        view.addSubview(label)

        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            icon.widthAnchor.constraint(equalToConstant: 52),
            icon.heightAnchor.constraint(equalToConstant: 52),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 16),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
    }
}
