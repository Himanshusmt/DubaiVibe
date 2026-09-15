import UIKit
import FirebaseCore
import GoogleSignIn
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LocalizationManager.shared.applySavedLanguage()
        FirebaseApp.configure()
        GoogleServiceConfig.configureGIDSignInIfPossible()
        UIFont.installInterAsSystemFont()
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = AppPalette.gold
        configureKeyboardManager()
        LaunchOverlay.begin()
        return true
    }

    private func configureKeyboardManager() {
        let keyboard = IQKeyboardManager.shared
        keyboard.isEnabled = true
        keyboard.resignOnTouchOutside = true
        keyboard.keyboardDistance = 24
        keyboard.disabledDistanceHandlingClasses.append(contentsOf: [
            SignupWithPhoneNumberVC.self,
            EnterOTPVC.self,
            OnboardingNameVC.self
        ])
        // Auth fields wrap UITextField in UIView chrome; treat the chrome as a control
        // so tapping another field focuses it instead of resigning the keyboard.
        keyboard.touchResignedGestureIgnoreClasses.append(contentsOf: [
            AuthDarkField.self,
            AuthPhoneInputView.self,
            AuthOTPView.self
        ])
    }

    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {}
}
