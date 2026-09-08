import UIKit

final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureAppearance()
        pinTabsToEdges()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stripGlassEffects()
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // Block taps on the invisible spacers that hold the icons at the edges.
        viewController.tabBarItem.tag != SpacerViewController.tag
    }
}

private extension MainTabBarController {
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
        tabBar.tintColor = AppPalette.gold
        tabBar.unselectedItemTintColor = AppPalette.tabIdle
        tabBar.isTranslucent = false
        tabBar.backgroundColor = AppPalette.background
        tabBar.barTintColor = AppPalette.background
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.clipsToBounds = true
    }

    func styleItems(_ layout: UITabBarItemAppearance) {
        layout.normal.iconColor = AppPalette.tabIdle
        layout.normal.titleTextAttributes = [
            .foregroundColor: AppPalette.tabIdle,
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]
        layout.selected.iconColor = AppPalette.gold
        layout.selected.titleTextAttributes = [
            .foregroundColor: AppPalette.gold,
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]
    }

    /// Five equal slots: Dashboard | spacer | spacer | spacer | Profile.
    /// That pins the two real tabs to the left and right edges instead of clustering them in the center.
    func pinTabsToEdges() {
        guard
            let controllers = viewControllers,
            controllers.count == 2,
            let dashboard = controllers.first,
            let profile = controllers.last
        else {
            return
        }

        viewControllers = [
            dashboard,
            SpacerViewController(),
            SpacerViewController(),
            SpacerViewController(),
            profile
        ]
        selectedIndex = 0
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

/// Empty, non-interactive tab used only for spacing.
private final class SpacerViewController: UIViewController {
    static let tag = 9_001

    override func loadView() {
        view = UIView()
        view.backgroundColor = AppPalette.background
        // Clear image still occupies a full tab slot, which is what spreads the real icons apart.
        tabBarItem = UITabBarItem(title: nil, image: UIImage(), selectedImage: UIImage())
        tabBarItem.tag = Self.tag
        tabBarItem.isEnabled = false
        tabBarItem.accessibilityElementsHidden = true
    }
}
