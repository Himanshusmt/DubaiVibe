import UIKit

enum L10n {
    static var ok: String { "common.ok".localized }
    static var cancel: String { "common.cancel".localized }
    static var error: String { "common.error".localized }
    static var help: String { "common.help".localized }
    static var skip: String { "common.skip".localized }
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
    static var noBusinessesYet: String { "explore.noBusinesses".localized }
    static var noMatchingBusinesses: String { "explore.noMatchingBusinesses".localized }

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
    static var accountProfile: String { "profile.accountTitle".localized }
    static var profileVIPMember: String { "profile.vipMember".localized }
    static var profileAccountSection: String { "profile.accountSection".localized }
    static var profileSupportSection: String { "profile.supportSection".localized }
    static var profileEditTitle: String { "profile.editTitle".localized }
    static var profileEditSubtitle: String { "profile.editSubtitle".localized }
    static var profileLanguageSubtitle: String { "profile.languageSubtitle".localized }
    static var profilePushTitle: String { "profile.pushTitle".localized }
    static var profilePushSubtitle: String { "profile.pushSubtitle".localized }
    static var profileFAQTitle: String { "profile.faqTitle".localized }
    static var profileFAQSubtitle: String { "profile.faqSubtitle".localized }
    static var profileTermsTitle: String { "profile.termsTitle".localized }
    static var profileTermsSubtitle: String { "profile.termsSubtitle".localized }
    static var profilePrivacySubtitle: String { "profile.privacySubtitle".localized }
    static var profileLogOut: String { "profile.logOut".localized }
    static var profileLogOutConfirm: String { "profile.logOutConfirm".localized }
    static var profileDeleteTitle: String { "profile.deleteTitle".localized }
    static var profileDeleteSubtitle: String { "profile.deleteSubtitle".localized }
    static var profileDeleteConfirm: String { "profile.deleteConfirm".localized }
    static var profileContactPlaceholder: String { "profile.contactPlaceholder".localized }
    static var profileVersionPrefix: String { "profile.versionPrefix".localized }
    static var profileDownloaders: String { "profile.downloaders".localized }

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
    static var exclusivePerk: String { "deal.exclusivePerk".localized }
    static var enterCodeTitle: String { "deal.enterCodeTitle".localized }
    static var enterCodeSubtitle: String { "deal.enterCodeSubtitle".localized }
    static var venuePasscode: String { "deal.venuePasscode".localized }
    static var enterVenueCodePlaceholder: String { "deal.enterVenueCodePlaceholder".localized }
    static var enterVenueCodeHint: String { "deal.enterVenueCodeHint".localized }
    static var enterCodeDone: String { "deal.done".localized }
    static var unlockOfferMissing: String { "deal.unlockMissing".localized }
    static var unlockOfferFailed: String { "deal.unlockFailed".localized }
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
    static var verifyOTP: String { "auth.verifyOTP".localized }
    static var enterOTPCode: String { "auth.enterOTP".localized }
    static var nameTitle: String { "auth.nameTitle".localized }
    static var nameSubtitle: String { "auth.nameSubtitle".localized }
    static var createAccount: String { "auth.createAccount".localized }
    static var welcomeTitle: String { "auth.welcomeTitle".localized }
    static var notificationsTitle: String {"auth.notifications".localized }
    static var welcomeSubtitle: String { "auth.welcomeSubtitle".localized }
    static var notificationSubtitle: String { "auth.notificationSubtitle".localized }
    static var connectWithPeople: String { "auth.connectPeople".localized }
    static var discoverPlaces: String { "auth.discoverPlaces".localized }
    static var getExclusiveDeal: String { "auth.getExclusiveDeal".localized }
    static var startExploring: String { "auth.startExploring".localized }
    static var enableNotifications: String { "auth.enableNotifications".localized }
    static var newMessages: String { "auth.newMessages".localized }
    static var exclusiveDeals: String { "auth.exclusiveDeals".localized }
    static var peopleNearYou: String { "auth.peopleNearYou".localized }
    static var notificationsSettingsHint: String { "auth.notificationsSettingsHint".localized }
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
        LocalizationManager.shared.format("membership.memberSince", String(year))
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
    static var deletePhoto: String { "picker.deletePhoto".localized }
    static var photoDeleted: String { "picker.photoDeleted".localized }

    static var notificationsToday: String { "notifications.today".localized }
    static var notificationsYesterday: String { "notifications.yesterday".localized }
    static var notificationsNewCount: String { "notifications.newCount".localized }
    static var notificationsOfferBadge: String { "notifications.offerBadge".localized }
    static var notificationsZumaTitle: String { "notifications.zumaTitle".localized }
    static var notificationsZumaBody: String { "notifications.zumaBody".localized }
    static var notificationsZumaMeta: String { "notifications.zumaMeta".localized }
    static var notificationsViewVoucher: String { "notifications.viewVoucher".localized }
    static var notificationsCelaViTitle: String { "notifications.celaViTitle".localized }
    static var notificationsCelaViBody: String { "notifications.celaViBody".localized }
    static var notificationsCelaViMeta: String { "notifications.celaViMeta".localized }
    static var notificationsReserveTable: String { "notifications.reserveTable".localized }
    static var notificationsVipTitle: String { "notifications.vipTitle".localized }
    static var notificationsVipBody: String { "notifications.vipBody".localized }
    static var notificationsVipMeta: String { "notifications.vipMeta".localized }
    static var notificationsStatusActive: String { "notifications.statusActive".localized }
    static var notificationsNobuTitle: String { "notifications.nobuTitle".localized }
    static var notificationsNobuBody: String { "notifications.nobuBody".localized }
    static var notificationsNobuMeta: String { "notifications.nobuMeta".localized }
    static var notificationsLoginTitle: String { "notifications.loginTitle".localized }
    static var notificationsLoginBody: String { "notifications.loginBody".localized }
    static var notificationsLoginMeta: String { "notifications.loginMeta".localized }
    static var notificationsReview: String { "notifications.review".localized }
    static var notificationsEmpty: String { "notifications.empty".localized }
    static func notificationsNewCountFormat(_ count: Int) -> String {
        LocalizationManager.shared.format("notifications.newCountFormat", count)
    }

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
            "Account Profile": L10n.accountProfile,
            "ONEVIBE VIP MEMBER": L10n.profileVIPMember,
            "ACCOUNT & PREFERENCES": L10n.profileAccountSection,
            "SUPPORT & LEGAL": L10n.profileSupportSection,
            "Edit Profile": L10n.profileEditTitle,
            "Update name, email & details": L10n.profileEditSubtitle,
            "Language": L10n.language,
            "App interface language": L10n.profileLanguageSubtitle,
            "Push Notifications": L10n.profilePushTitle,
            "Exclusive venue offers & alerts": L10n.profilePushSubtitle,
            "FAQ & Concierge Support": L10n.profileFAQTitle,
            "Get assistance 24/7 in Dubai": L10n.profileFAQSubtitle,
            "Terms and Conditions": L10n.profileTermsTitle,
            "Membership agreement": L10n.profileTermsSubtitle,
            "Privacy Policy": L10n.privacyPolicy,
            "Security & data governance": L10n.profilePrivacySubtitle,
            "Log Out": L10n.profileLogOut,
            "Delete Account": L10n.profileDeleteTitle,
            "Permanently erase your OneVibe profile": L10n.profileDeleteSubtitle,
            "REAL PEOPLE": L10n.realPeople,
            "REAL EXPERIENCES": L10n.realExperiences,
            "Continue with Phone Number": L10n.continueWithPhone,
            "Continue with Apple": L10n.continueWithApple,
            "Continue with Google": L10n.continueWithGoogle,
            "or": L10n.or,
            "Help": L10n.help,
            "Skip": L10n.skip,
            "What's your phone number?": L10n.phoneTitle,
            "We'll send you a verification code \nto get you started.": L10n.phoneSubtitle,
            "Enter mobile number": L10n.enterMobileNumber,
            "Send OTP": L10n.sendOTP,
            "Verify OTP": L10n.verifyOTP,
            "Your number is secure and will never \nbe shared with anyone.": L10n.phoneSecure,
            "Enter the 6-digit code": L10n.otpTitle,
            "We sent a verification code to": L10n.otpSentPrefix.trimmingCharacters(in: .newlines),
            "What's your full name?": L10n.nameTitle,
            "This will be shown on your profile.": L10n.nameSubtitle,
            "Create Account": L10n.createAccount,
            "Welcome to DubaiVibe!": L10n.welcomeTitle,
            "Your account is ready.": L10n.welcomeSubtitle,
            "Turn on Notifications?": L10n.notificationsTitle,
            "Get updates, messages and exclusive\ndeals from Dubai Vibe.": L10n.notificationSubtitle,
            "Connect \nwith people": L10n.connectWithPeople,
            "Discover amazing places": L10n.discoverPlaces,
            " Get exclusive \ndeal": L10n.getExclusiveDeal,
            "Start Exploring": L10n.startExploring,
            "Enable Notifications": L10n.enableNotifications,
            "New\nMessages": L10n.newMessages,
            "Exclusive\nDeals": L10n.exclusiveDeals,
            "People\nNear You": L10n.peopleNearYou,
            "You can change this anytime\nin Settings.": L10n.notificationsSettingsHint,
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
            "DUBAI VIBE EXCLUSIVE PERK": L10n.exclusivePerk,
            "Enter Code": L10n.enterCodeTitle,
            "Ask restaurant member to enter the code": L10n.enterCodeSubtitle,
            "VENUE PASSCODE": L10n.venuePasscode,
            "enter venue code": L10n.enterVenueCodePlaceholder,
            "Enter the alphanumeric code provided by your server": L10n.enterVenueCodeHint,
            "Done": L10n.done,
            "Done ✓": L10n.enterCodeDone,
            "Almost there!": L10n.almostThere,
            "Verify your membership\nto unlock this exclusive offer.": L10n.membershipSubtitle,
            "Verified Member": L10n.verifiedMember,
            "OneVibe Member since 2024": L10n.memberSince(2024),
            "DubaiVibe Member since 2024": L10n.memberSince(2024),
            "Real People": "membership.realPeople".localized,
            "Exclusive Deals": L10n.exclusiveDeals.replacingOccurrences(of: "\n", with: " "),
            "Better Experiences": L10n.betterExperiences,
            "YOUR VERIFIED CODE": L10n.yourVerifiedCode,
            "Show this code to the staff\nto get your exclusive discount.": L10n.showCodeToStaff,
            "Date": L10n.date,
            "Time": L10n.time,
            "Valid Until": L10n.validUntil,
            "Valid For": L10n.validFor,
            "Usage": "membership.usage".localized,
            "One-time use only": L10n.oneTimeUse,
            "This code can only be used once.": L10n.codeOnce,
            "Notifications": L10n.notifications,
            "TODAY": L10n.notificationsToday,
            "YESTERDAY": L10n.notificationsYesterday,
            "2 new": L10n.notificationsNewCount,
            "  30% OFF  ": L10n.notificationsOfferBadge,
            "Zuma Dubai": L10n.notificationsZumaTitle,
            "Your exclusive OneVibe discount voucher is ready for dinner reservations tonight at DIFC.": L10n.notificationsZumaBody,
            "12m ago • Dining Exclusive": L10n.notificationsZumaMeta,
            "View Voucher": L10n.notificationsViewVoucher,
            "Trending at CÉ LA VI": L10n.notificationsCelaViTitle,
            "Sunset rooftop lounge tables are booking fast for tonight with panoramic Burj Khalifa views.": L10n.notificationsCelaViBody,
            "1h ago • Downtown Dubai": L10n.notificationsCelaViMeta,
            "Reserve Table →": L10n.notificationsReserveTable,
            "VIP Tier Verified": L10n.notificationsVipTitle,
            "Your membership status is active. Enjoy priority reservations and exclusive member rates.": L10n.notificationsVipBody,
            "3h ago • Membership": L10n.notificationsVipMeta,
            "Status: Active": L10n.notificationsStatusActive,
            "New Partner: Nobu Dubai": L10n.notificationsNobuTitle,
            "Discover Japanese-Peruvian cuisine and exclusive OneVibe offerings at our newest partner venue.": L10n.notificationsNobuBody,
            "5h ago • Partners": L10n.notificationsNobuMeta,
            "New Login Detected": L10n.notificationsLoginTitle,
            "A new device signed in to your Dubai Vibe account. If this wasn’t you, review your security settings.": L10n.notificationsLoginBody,
            "Yesterday • Security": L10n.notificationsLoginMeta,
            "Review": L10n.notificationsReview
        ]
    }
}

extension UIViewController {
    func applyLocalizedStoryboardCopy() {
        view.applyLocalizedStoryboardCopy()
    }
}
