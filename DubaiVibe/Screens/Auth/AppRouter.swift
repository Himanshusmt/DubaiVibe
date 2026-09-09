import UIKit

enum AppRouter {
    static func isLoggedIn() -> Bool {
        UserDefaults.standard.isLoggedIn() || TokenManager.shared.isLoggedIn
    }

    static func markMockSessionComplete() {
        UserDefaults.standard.setLoggedIn(value: true)
        TokenManager.shared.saveAccessToken("mock-token")
        TokenManager.shared.isOnboardingCompleted = true
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
        if isLoggedIn() {
            window.rootViewController = UIStoryboard.main.instantiateViewController(
                withIdentifier: "MainTabBarController"
            )
        } else {
            window.rootViewController = makeAuthRoot()
        }
        window.makeKeyAndVisible()
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
