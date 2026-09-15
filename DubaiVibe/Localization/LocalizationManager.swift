import Foundation

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case russian = "ru"

    var code: String { rawValue }

    var nativeName: String {
        switch self {
        case .english: return "English"
        case .russian: return "Русский"
        }
    }

    var locale: Locale {
        Locale(identifier: code)
    }
}

final class LocalizationManager {
    static let shared = LocalizationManager()
    static let didChangeNotification = Notification.Name("LocalizationManager.didChange")

    private static let storageKey = "app.language"

    private(set) var language: AppLanguage
    private(set) var bundle: Bundle

    var locale: Locale { language.locale }

    private init() {
        language = Self.resolveLanguage()
        bundle = Self.bundle(for: language)
        Self.pinSystemLanguage(language)
    }

    /// Call once at launch so UIKit and string lookups share the saved language.
    func applySavedLanguage() {
        language = Self.resolveLanguage()
        bundle = Self.bundle(for: language)
        Self.pinSystemLanguage(language)
    }

    /// Returns `true` when the language actually changed.
    @discardableResult
    func setLanguage(_ language: AppLanguage) -> Bool {
        guard language != self.language else { return false }
        self.language = language
        UserDefaults.standard.set(language.code, forKey: Self.storageKey)
        bundle = Self.bundle(for: language)
        Self.pinSystemLanguage(language)
        NotificationCenter.default.post(name: Self.didChangeNotification, object: language)
        return true
    }

    func localized(_ key: String) -> String {
        let value = bundle.localizedString(forKey: key, value: nil, table: nil)
        if value != key { return value }
        return Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }

    func format(_ key: String, _ args: CVarArg...) -> String {
        String(format: localized(key), locale: locale, arguments: args)
    }

    private static func resolveLanguage() -> AppLanguage {
        if let code = UserDefaults.standard.string(forKey: storageKey),
           let saved = AppLanguage(rawValue: code) {
            return saved
        }
        let preferred = Locale.preferredLanguages.first?.lowercased() ?? "en"
        return preferred.hasPrefix("ru") ? .russian : .english
    }

    private static func bundle(for language: AppLanguage) -> Bundle {
        if let path = Bundle.main.path(forResource: language.code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }

    private static func pinSystemLanguage(_ language: AppLanguage) {
        UserDefaults.standard.set([language.code], forKey: "AppleLanguages")
    }
}

extension String {
    var localized: String {
        LocalizationManager.shared.localized(self)
    }
}
