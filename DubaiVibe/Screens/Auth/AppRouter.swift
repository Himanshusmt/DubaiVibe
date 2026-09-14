import UIKit

enum AppRouter {
    private static let mockAccessToken = "mock-token"

    static func isLoggedIn() -> Bool {
        guard let token = TokenManager.shared.accessToken,
              !token.isEmpty,
              token != mockAccessToken
        else {
            return false
        }
        return true
    }

    static func makeAuthRoot() -> UIViewController {
        let welcome = UIStoryboard.authentication
            .instantiateViewController(withIdentifier: "WelcomeVC")
        let nav = UINavigationController(rootViewController: welcome)
        nav.setNavigationBarHidden(true, animated: false)
        nav.navigationBar.isHidden = true
        return nav
    }

    static func setRootAuth(animated: Bool = false) {
        guard let window = keyWindow() else { return }
        setRoot(makeAuthRoot(), on: window, animated: animated)
    }

    static func setRootMain(animated: Bool = true) {
        guard let window = keyWindow() else { return }
        let root = UIStoryboard.main.instantiateViewController(withIdentifier: "MainTabBarController")
        setRoot(root, on: window, animated: animated)
    }

    static func configureRoot(for window: UIWindow) {
        clearStaleMockSessionIfNeeded()

        if isLoggedIn() {
            window.rootViewController = UIStoryboard.main.instantiateViewController(
                withIdentifier: "MainTabBarController"
            )
        } else {
            window.rootViewController = makeAuthRoot()
        }
        window.makeKeyAndVisible()
    }

    /// Clears signup mock login left from older builds so cold start shows Welcome.
    private static func clearStaleMockSessionIfNeeded() {
        let defaults = UserDefaults.standard
        let hasMockToken = TokenManager.shared.accessToken == mockAccessToken
        let hasLegacyLoginFlag = defaults.isLoggedIn() && !TokenManager.shared.isLoggedIn

        guard hasMockToken || hasLegacyLoginFlag else { return }

        TokenManager.shared.clearUnauthorizedSession()
        defaults.removeObject(forKey: UserDefaultsKeys.isLoggedIn.rawValue)
    }

    private static func setRoot(_ root: UIViewController?, on window: UIWindow, animated: Bool) {
        guard let root else { return }
        if animated {
            UIView.transition(
                with: window,
                duration: 0.25,
                options: .transitionCrossDissolve,
                animations: { window.rootViewController = root },
                completion: nil
            )
        } else {
            window.rootViewController = root
        }
    }

    private static func keyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
            ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first
    }
}
