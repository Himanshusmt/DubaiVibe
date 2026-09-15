import UIKit

enum VenueCategory: String, CaseIterable, Hashable {
    case all
    case restaurants
    case bars
    case nightlife
    case cafes
    case brunches
    case beachClubs
    case ladiesNights
    case gymsFitness
    case padelTennis
    case beautySalons

    var title: String {
        switch self {
        case .all: return L10n.categoryAll
        case .restaurants: return L10n.categoryRestaurants
        case .bars: return L10n.categoryBars
        case .nightlife: return L10n.categoryNightlife
        case .cafes: return L10n.categoryCafes
        case .brunches: return L10n.categoryBrunches
        case .beachClubs: return L10n.categoryBeachClubs
        case .ladiesNights: return L10n.categoryLadiesNights
        case .gymsFitness: return L10n.categoryGyms
        case .padelTennis: return L10n.categoryPadel
        case .beautySalons: return L10n.categoryBeauty
        }
    }

    /// `nil` keeps the "All" chip text-only, as in the design.
    var icon: UIImage? {
        switch self {
        case .all:
            return nil
        case .restaurants:
            return UIImage(named: "ExploreFood")
        case .bars:
            return UIImage(named: "ExploreDrink")
        case .nightlife:
            return UIImage(named: "ExploreNightlife")
        case .cafes:
            return UIImage(named: "ExploreCafe")
        case .brunches:
            return UIImage(named: "ExploreBrunch")
        case .beachClubs:
            return UIImage(named: "ExploreBeach")
        case .ladiesNights:
            return UIImage(named: "ExploreLadies")
        case .gymsFitness:
            return UIImage(named: "ExploreGym")
        case .padelTennis:
            return UIImage(named: "ExplorePadel")
        case .beautySalons:
            return UIImage(named: "ExploreBeauty")
        }
    }
}

enum ArtworkStyle: String, Hashable {
    case zuma
    case rooftop
    case izakaya
    case lounge
    case cafe
    case club
    case beach
    case brunch
    case wellness
    case court
    case salon
}

struct Deal: Hashable {
    static var exclusiveBadge: String { L10n.exclusiveBadge }

    /// Used when a venue has no API/mock deal so every Explore card still shows the banner.
    static var fallback: Deal {
        Deal(
            discount: "15% OFF",
            detail: "Your total bill",
            validity: "Sunday – Thursday"
        )
    }

    var badge: String = Deal.exclusiveBadge
    let discount: String
    let detail: String
    let validity: String
}

struct Venue: Hashable, Identifiable {
    let id: UUID
    var name: String
    var wordmark: String
    var category: VenueCategory
    var cuisine: String
    var neighborhood: String
    var rating: Double
    var reviewCount: Int
    var deal: Deal?
    var isFavorite: Bool
    var isBookmarked: Bool
    var isVerified: Bool
    var artworkStyle: ArtworkStyle

    var subtitle: String { "\(cuisine) • \(neighborhood)" }

    var ratingValueText: String { String(format: "%.1f", rating) }

    var reviewCountText: String {
        guard reviewCount >= 1000 else { return "(\(reviewCount))" }
        let value = Double(reviewCount) / 1000.0
        return String(format: value >= 10 ? "(%.0fK)" : "(%.1fK)", value)
    }

    var photoImage: UIImage? {
        switch artworkStyle {
        case .zuma: return UIImage(named: "VenueZuma")
        case .rooftop: return UIImage(named: "VenueCeLaVi")
        default: return nil
        }
    }
}
