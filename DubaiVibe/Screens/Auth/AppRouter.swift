import UIKit

enum AppRouter {
    private static var bootstrapAuth: AuthViewModel?

    /// Token present and `isOnboardingComplete == true` → Explore.
    /// `false`, `null`, or missing token → SignupOptionsVC.
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
            .instantiateViewController(withIdentifier: "SignupOptionsVC")
        let nav = UINavigationController(rootViewController: welcome)
        nav.setNavigationBarHidden(true, animated: false)
        nav.navigationBar.isHidden = true
        return nav
    }

    static func setRootAuth(animated: Bool = false) {
        guard let window = keyWindow() else { return }
        setRoot(makeAuthRoot(), on: window, animated: animated)
    }

    static func setRootMain(animated: Bool = true, selectingProfile: Bool = false) {
        guard let window = keyWindow() else { return }
        let root = makeMainRoot()
        if selectingProfile, let tabs = root as? UITabBarController {
            tabs.selectedIndex = min(1, (tabs.viewControllers?.count ?? 1) - 1)
        }
        setRoot(root, on: window, animated: animated)
    }

    /// Rebuilds the current root so every screen picks up a newly selected language.
    static func reloadInterface(selectingProfile: Bool = false) {
        guard let window = keyWindow() else { return }
        let showingMain = isShowingMain(window.rootViewController)
        if showingMain {
            setRootMain(animated: true, selectingProfile: selectingProfile)
        } else {
            setRootAuth(animated: true)
        }
    }

    static func configureRoot(for window: UIWindow) {
        let token = TokenManager.shared.accessToken?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if token.isEmpty {
            TokenManager.shared.isOnboardingCompleted = false
            window.rootViewController = makeAuthRoot()
            window.makeKeyAndVisible()
            return
        }

        window.rootViewController = hasCompletedOnboarding() ? makeMainRoot() : makeAuthRoot()
        window.makeKeyAndVisible()
        refreshRootFromProfile(on: window)
    }

    /// Apply `isOnboardingComplete` from verify-OTP / get-profile.
    /// `true` → Explore. `false` or `null` → SignupOptionsVC (or remaining onboarding after login).
    static func applyOnboardingGate(isOnboardingComplete: Bool?, animated: Bool = true) {
        let completed = isOnboardingComplete == true
        TokenManager.shared.isOnboardingCompleted = completed
        if completed {
            UserDefaults.standard.setLoggedIn(value: true)
        }

        guard let window = keyWindow() else { return }
        applyRoot(completed: completed, on: window, animated: animated)
    }

    /// After login: Explore if onboarding is complete, otherwise continue the name / welcome flow.
    static func continueAfterLogin(
        from viewController: UIViewController,
        user: AuthUser?,
        isOnboardingComplete: Bool? = nil,
        firstName: String? = nil,
        lastName: String? = nil
    ) {
        let completed = isOnboardingComplete ?? user?.isOnboardingComplete
        TokenManager.shared.isOnboardingCompleted = completed == true

        if completed == true {
            UserDefaults.standard.setLoggedIn(value: true)
            setRootMain(animated: true)
            return
        }

        guard let nameVC = UIStoryboard.authentication
            .instantiateViewController(withIdentifier: "OnboardingNameVC") as? OnboardingNameVC
        else {
            setRootAuth(animated: true)
            return
        }

        nameVC.prefillFirstName = firstName ?? user?.resolvedFirstName
        nameVC.prefillLastName = lastName ?? user?.resolvedLastName
        if let nav = viewController.navigationController {
            nav.pushViewController(nameVC, animated: true)
        } else {
            setRootAuth(animated: true)
        }
    }

    private static func refreshRootFromProfile(on window: UIWindow) {
        let auth = AuthViewModel()
        bootstrapAuth = auth
        auth.fetchCurrentUser(showLoader: false) { result in
            bootstrapAuth = nil
            switch result {
            case .success(let response):
                applyRoot(
                    completed: response.resolvedOnboardingComplete,
                    on: window,
                    animated: true
                )
            case .failure:
                break
            }
        }
    }

    private static func applyRoot(completed: Bool, on window: UIWindow, animated: Bool) {
        let showingMain = isShowingMain(window.rootViewController)
        if completed {
            if !showingMain {
                setRoot(makeMainRoot(), on: window, animated: animated)
            }
        } else if showingMain {
            setRoot(makeAuthRoot(), on: window, animated: animated)
        }
    }

    private static func makeMainRoot() -> UIViewController {
        UIStoryboard.main.instantiateViewController(withIdentifier: "MainTabBarController")
    }

    private static func isShowingMain(_ root: UIViewController?) -> Bool {
        root is MainTabBarController || (root as? UITabBarController) != nil
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
