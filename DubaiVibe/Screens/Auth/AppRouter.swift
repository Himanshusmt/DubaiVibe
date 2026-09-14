import UIKit

enum AppRouter {
    /// Token present and `is_onboarding_complete == true` → Explore.
    /// Otherwise (no token, or onboarding still false) → Welcome.
    static func hasCompletedOnboarding() -> Bool {
        let token = TokenManager.shared.accessToken?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return !token.isEmpty && TokenManager.shared.isOnboardingCompleted
    }

    static func isLoggedIn() -> Bool {
        hasCompletedOnboarding()
    }

    static func completeOnboarding() {
        TokenManager.shared.isOnboardingCompleted = true
        UserDefaults.standard.setLoggedIn(value: true)
    }

    static func markMockSessionComplete() {
        completeOnboarding()
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
        if hasCompletedOnboarding() {
            window.rootViewController = UIStoryboard.main.instantiateViewController(
                withIdentifier: "MainTabBarController"
            )
        } else {
            window.rootViewController = makeAuthRoot()
        }
        window.makeKeyAndVisible()
    }

    /// After login: Explore if onboarding is complete, otherwise continue the welcome/profile flow.
    static func continueAfterLogin(
        from viewController: UIViewController,
        user: AuthUser?,
        firstName: String? = nil,
        lastName: String? = nil
    ) {
        if hasCompletedOnboarding() {
            setRootMain(animated: true)
            return
        }

        guard let nameVC = UIStoryboard.authentication
            .instantiateViewController(withIdentifier: "OnboardingNameVC") as? OnboardingNameVC
        else { return }

        nameVC.prefillFirstName = firstName
        nameVC.prefillLastName = lastName
        viewController.navigationController?.pushViewController(nameVC, animated: true)
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
