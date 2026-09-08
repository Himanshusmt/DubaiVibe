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
        case .all: return "All"
        case .restaurants: return "Restaurants"
        case .bars: return "Bars"
        case .nightlife: return "Nightlife"
        case .cafes: return "Cafés"
        case .brunches: return "Brunch"
        case .beachClubs: return "Beach Clubs"
        case .ladiesNights: return "Ladies Nights"
        case .gymsFitness: return "Gyms & Fitness"
        case .padelTennis: return "Padel & Tennis"
        case .beautySalons: return "Beauty & Salons"
        }
    }

    /// `nil` keeps the "All" chip text-only, as in the design.
    var icon: UIImage? {
        switch self {
        case .all: return nil
        case .restaurants: return UIImage(systemName: "fork.knife")
        case .bars: return BrandGlyphs.martini
        case .nightlife: return BrandGlyphs.discoBall
        case .cafes: return BrandGlyphs.mug
        case .brunches: return UIImage(systemName: "sun.horizon.fill")
        case .beachClubs: return UIImage(systemName: "beach.umbrella")
        case .ladiesNights: return UIImage(systemName: "figure.dance")
        case .gymsFitness: return UIImage(systemName: "dumbbell")
        case .padelTennis: return UIImage(systemName: "tennis.racket")
        case .beautySalons: return UIImage(systemName: "scissors")
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
    static let exclusiveBadge = "DUBAI VIBE EXCLUSIVE"

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

    var subtitle: String { "\(cuisine)  •  \(neighborhood)" }

    var ratingValueText: String { String(format: "%.1f", rating) }

    var reviewCountText: String {
        guard reviewCount >= 1000 else { return "(\(reviewCount))" }
        let value = Double(reviewCount) / 1000.0
        return String(format: value >= 10 ? "(%.0fK)" : "(%.1fK)", value)
    }
}
