import UIKit

enum L10n {
    static var ok: String { "common.ok".localized }
    static var cancel: String { "common.cancel".localized }
    static var error: String { "common.error".localized }
    static var help: String { "common.help".localized }
    static var comingSoon: String { "common.comingSoon".localized }
    static var save: String { "common.save".localized }
    static var notifications: String { "common.notifications".localized }
    static var back: String { "common.back".localized }
    static var close: String { "common.close".localized }
    static var clear: String { "common.clear".localized }
    static var done: String { "common.done".localized }
    static var brandName: String { "common.brandName".localized }

    static var home: String { "tab.home".localized }
    static var profile: String { "tab.profile".localized }

    static var tagline: String { "explore.tagline".localized }
    static var searchPlaceholder: String { "explore.searchPlaceholder".localized }
    static var cityDubai: String { "explore.cityDubai".localized }
    static var cityAbuDhabi: String { "explore.cityAbuDhabi".localized }
    static var cityDubaiAccessibility: String { "explore.cityDubaiAccessibility".localized }

    static var firstName: String { "profile.firstName".localized }
    static var lastName: String { "profile.lastName".localized }
    static var saved: String { "profile.saved".localized }
    static var profileUpdated: String { "profile.updated".localized }
    static var language: String { "profile.language".localized }
    static var enterFirstName: String { "profile.enterFirstName".localized }
    static var firstNameTooShort: String { "profile.firstNameTooShort".localized }
    static var invalidFirstName: String { "profile.invalidFirstName".localized }
    static var enterLastName: String { "profile.enterLastName".localized }
    static var lastNameTooShort: String { "profile.lastNameTooShort".localized }
    static var invalidLastName: String { "profile.invalidLastName".localized }

    static var categoryAll: String { "category.all".localized }
    static var categoryRestaurants: String { "category.restaurants".localized }
    static var categoryBars: String { "category.bars".localized }
    static var categoryNightlife: String { "category.nightlife".localized }
    static var categoryCafes: String { "category.cafes".localized }
    static var categoryBrunches: String { "category.brunches".localized }
    static var categoryBeachClubs: String { "category.beachClubs".localized }
    static var categoryLadiesNights: String { "category.ladiesNights".localized }
    static var categoryGyms: String { "category.gyms".localized }
    static var categoryPadel: String { "category.padel".localized }
    static var categoryBeauty: String { "category.beauty".localized }

    static var viewDeal: String { "deal.view".localized }
    static var unlockDeal: String { "deal.unlock".localized }
    static var exclusiveBadge: String { "deal.exclusiveBadge".localized }
    static var favorite: String { "deal.favorite".localized }
    static var bookmark: String { "deal.bookmark".localized }

    static var realPeople: String { "auth.realPeople".localized }
    static var realExperiences: String { "auth.realExperiences".localized }
    static var continueWithPhone: String { "auth.continuePhone".localized }
    static var continueWithApple: String { "auth.continueApple".localized }
    static var continueWithGoogle: String { "auth.continueGoogle".localized }
    static var or: String { "auth.or".localized }
    static var termsPrefix: String { "auth.termsPrefix".localized }
    static var termsOfService: String { "auth.termsOfService".localized }
    static var termsAnd: String { "auth.termsAnd".localized }
    static var privacyPolicy: String { "auth.privacyPolicy".localized }
    static var termsSoon: String { "auth.termsSoon".localized }
    static var privacySoon: String { "auth.privacySoon".localized }
    static var phoneTitle: String { "auth.phoneTitle".localized }
    static var phoneSubtitle: String { "auth.phoneSubtitle".localized }
    static var enterMobileNumber: String { "auth.enterMobile".localized }
    static var sendOTP: String { "auth.sendOTP".localized }
    static var phoneSecure: String { "auth.phoneSecure".localized }
    static var phoneHelpMessage: String { "auth.phoneHelp".localized }
    static var enterPhoneNumber: String { "auth.enterPhone".localized }
    static var invalidUAEPhoneNumber: String { "auth.invalidUAEPhone".localized }
    static var otpTitle: String { "auth.otpTitle".localized }
    static var otpSentPrefix: String { "auth.otpSentPrefix".localized }
    static var otpDidntReceive: String { "auth.otpDidntReceive".localized }
    static var otpResend: String { "auth.otpResend".localized }
    static func otpResendIn(minutes: Int, seconds: Int) -> String {
        LocalizationManager.shared.format("auth.otpResendIn", minutes, seconds)
    }
    static var nameTitle: String { "auth.nameTitle".localized }
    static var nameSubtitle: String { "auth.nameSubtitle".localized }
    static var createAccount: String { "auth.createAccount".localized }
    static var welcomeTitle: String { "auth.welcomeTitle".localized }
    static var welcomeSubtitle: String { "auth.welcomeSubtitle".localized }
    static var connectWithPeople: String { "auth.connectPeople".localized }
    static var discoverPlaces: String { "auth.discoverPlaces".localized }
    static var getExclusiveDeal: String { "auth.getExclusiveDeal".localized }
    static var startExploring: String { "auth.startExploring".localized }
    static var enableNotifications: String { "auth.enableNotifications".localized }
    static var newMessages: String { "auth.newMessages".localized }
    static var exclusiveDeals: String { "auth.exclusiveDeals".localized }
    static var peopleNearYou: String { "auth.peopleNearYou".localized }
    static var appleMissingToken: String { "auth.appleMissingToken".localized }
    static var googleNotConfigured: String { "auth.googleNotConfigured".localized }
    static func googleMissingScheme(_ scheme: String) -> String {
        LocalizationManager.shared.format("auth.googleMissingScheme", scheme)
    }
    static var googleMissingToken: String { "auth.googleMissingToken".localized }

    static var photos: String { "venue.photos".localized }
    static func photosCount(_ count: Int) -> String {
        LocalizationManager.shared.format("venue.photosCount", count)
    }
    static var directions: String { "venue.directions".localized }
    static var openingHours: String { "venue.openingHours".localized }
    static var call: String { "venue.call".localized }
    static var website: String { "venue.website".localized }
    static var instagram: String { "venue.instagram".localized }
    static var share: String { "venue.share".localized }
    static var oneVibe: String { "venue.oneVibe".localized }
    static var about: String { "venue.about".localized }
    static var menu: String { "venue.menu".localized }
    static var vibes: String { "venue.vibes".localized }
    static var deals: String { "venue.deals".localized }
    static var reviews: String { "venue.reviews".localized }
    static var menuComingSoon: String { "venue.menuComingSoon".localized }
    static var vibesComingSoon: String { "venue.vibesComingSoon".localized }
    static var reviewsComingSoon: String { "venue.reviewsComingSoon".localized }
    static var noDeals: String { "venue.noDeals".localized }
    static var watchVibe: String { "venue.watchVibe".localized }

    static var almostThere: String { "membership.almostThere".localized }
    static var membershipSubtitle: String { "membership.subtitle".localized }
    static var verifiedMember: String { "membership.verifiedMember".localized }
    static func memberSince(_ year: Int) -> String {
        LocalizationManager.shared.format("membership.memberSince", year)
    }
    static var yourVerifiedCode: String { "membership.yourVerifiedCode".localized }
    static var copyCode: String { "membership.copyCode".localized }
    static var copyCodeHint: String { "membership.copyHint".localized }
    static var codeCopied: String { "membership.codeCopied".localized }
    static var date: String { "membership.date".localized }
    static var time: String { "membership.time".localized }
    static var validUntil: String { "membership.validUntil".localized }
    static var validFor: String { "membership.validFor".localized }
    static var minutes: String { "membership.minutes".localized }
    static var oneTimeUse: String { "membership.oneTimeUse".localized }
    static var codeOnce: String { "membership.codeOnce".localized }
    static var betterExperiences: String { "membership.betterExperiences".localized }
    static var showCodeToStaff: String { "membership.showCodeToStaff".localized }
    static var membershipHelp: String { "membership.helpMessage".localized }

    static var takePhoto: String { "picker.takePhoto".localized }
    static var photoLibrary: String { "picker.photoLibrary".localized }

    static var sessionExpired: String { "session.expiredTitle".localized }
    static var sessionExpiredMessage: String { "session.expiredMessage".localized }
}

extension UIView {
    /// Replaces known English storyboard copy after the view loads from Base.
    func applyLocalizedStoryboardCopy() {
        let map = Self.storyboardCopyMap
        localizeCopy(using: map)
    }

    private func localizeCopy(using map: [String: String]) {
        if let label = self as? UILabel, let text = label.text, let replacement = map[text] {
            label.text = replacement
        }
        if let field = self as? UITextField {
            if let placeholder = field.placeholder, let replacement = map[placeholder] {
                var attributes: [NSAttributedString.Key: Any] = [.foregroundColor: AppPalette.secondaryText]
                if let attributed = field.attributedPlaceholder, attributed.length > 0 {
                    attributes = attributed.attributes(at: 0, effectiveRange: nil)
                }
                field.attributedPlaceholder = NSAttributedString(string: replacement, attributes: attributes)
            }
            if let text = field.text, let replacement = map[text] {
                field.text = replacement
            }
        }
        if let view = self as? UITextView,
           view.attributedText.length == 0,
           let text = view.text,
           let replacement = map[text] {
            view.text = replacement
        }
        if let button = self as? UIButton, let title = button.currentTitle, let replacement = map[title] {
            button.setTitle(replacement, for: .normal)
        }
        subviews.forEach { $0.localizeCopy(using: map) }
    }

    private static var storyboardCopyMap: [String: String] {
        [
            "DUBAI • EAT • DRINK • EXPLORE": L10n.tagline,
            "Search restaurants, bars, nightlife, beaches...": L10n.searchPlaceholder,
            "Dubai": L10n.cityDubai,
            "Save": L10n.save,
            "Home": L10n.home,
            "Profile": L10n.profile,
            "REAL PEOPLE": L10n.realPeople,
            "REAL EXPERIENCES": L10n.realExperiences,
            "Continue with Phone Number": L10n.continueWithPhone,
            "Continue with Apple": L10n.continueWithApple,
            "Continue with Google": L10n.continueWithGoogle,
            "or": L10n.or,
            "Help": L10n.help,
            "What's your phone number?": L10n.phoneTitle,
            "We'll send you a verification code to get you started.": L10n.phoneSubtitle,
            "Enter mobile number": L10n.enterMobileNumber,
            "Send OTP": L10n.sendOTP,
            "Your number is secure and will never be shared with anyone.": L10n.phoneSecure,
            "Enter the 6-digit code": L10n.otpTitle,
            "We sent a verification code to": L10n.otpSentPrefix.trimmingCharacters(in: .newlines),
            "What's your full name?": L10n.nameTitle,
            "This will be shown on your profile.": L10n.nameSubtitle,
            "Create Account": L10n.createAccount,
            "Welcome to DubaiVibe!": L10n.welcomeTitle,
            "Your account is ready.": L10n.welcomeSubtitle,
            "Connect with people": L10n.connectWithPeople,
            "Discover amazing places": L10n.discoverPlaces,
            " Get exclusive                                deal": L10n.getExclusiveDeal,
            "Start Exploring": L10n.startExploring,
            "Enable Notifications": L10n.enableNotifications,
            "New                               Messages": L10n.newMessages,
            "Exclusive\nDeals": L10n.exclusiveDeals,
            "People                               Near You": L10n.peopleNearYou,
            "Photos": L10n.photos,
            "Watch Vibe": L10n.watchVibe,
            "Directions": L10n.directions,
            "Call": L10n.call,
            "Website": L10n.website,
            "Instagram": L10n.instagram,
            "OneVibe": L10n.oneVibe,
            "Share": L10n.share,
            "About": L10n.about,
            "Menu": L10n.menu,
            "Vibes": L10n.vibes,
            "Deals": L10n.deals,
            "Reviews": L10n.reviews,
            "Unlock Deal": L10n.unlockDeal,
            "View Deal": L10n.viewDeal,
            "Almost there!": L10n.almostThere,
            "Verify your membership\nto unlock this exclusive offer.": L10n.membershipSubtitle,
            "Verified Member": L10n.verifiedMember,
            "Real People": "membership.realPeople".localized,
            "Exclusive Deals": L10n.exclusiveDeals,
            "Better Experiences": L10n.betterExperiences,
            "YOUR VERIFIED CODE": L10n.yourVerifiedCode,
            "Show this code to the staff\nto get your exclusive discount.": L10n.showCodeToStaff,
            "Date": L10n.date,
            "Time": L10n.time,
            "Valid Until": L10n.validUntil,
            "Valid For": L10n.validFor,
            "Usage": "membership.usage".localized,
            "One-time use only": L10n.oneTimeUse,
            "This code can only be used once.": L10n.codeOnce
        ]
    }
}

extension UIViewController {
    func applyLocalizedStoryboardCopy() {
        view.applyLocalizedStoryboardCopy()
    }
}
