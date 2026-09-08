import Foundation

enum VenueCategory: String, CaseIterable, Hashable {
    case all
    case restaurants
    case nightclubs
    case barsLounges
    case brunches
    case beachClubs
    case ladiesNights
    case cafes
    case gymsFitness
    case padelTennis
    case beautySalons

    var title: String {
        switch self {
        case .all: return "All"
        case .restaurants: return "Restaurants"
        case .nightclubs: return "Nightclubs"
        case .barsLounges: return "Bars & Lounges"
        case .brunches: return "Brunches"
        case .beachClubs: return "Beach Clubs"
        case .ladiesNights: return "Ladies Nights"
        case .cafes: return "Cafés"
        case .gymsFitness: return "Gyms & Fitness"
        case .padelTennis: return "Padel & Tennis"
        case .beautySalons: return "Beauty & Salons"
        }
    }

    /// `nil` keeps the "All" chip text-only, as in the design.
    var symbolName: String? {
        switch self {
        case .all: return nil
        case .restaurants: return "fork.knife"
        case .nightclubs: return "music.note"
        case .barsLounges: return "wineglass"
        case .brunches: return "sun.horizon.fill"
        case .beachClubs: return "beach.umbrella"
        case .ladiesNights: return "figure.dance"
        case .cafes: return "cup.and.saucer"
        case .gymsFitness: return "dumbbell"
        case .padelTennis: return "tennis.racket"
        case .beautySalons: return "scissors"
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

    var ratingText: String {
        let count: String
        if reviewCount >= 1000 {
            let value = Double(reviewCount) / 1000.0
            count = String(format: value >= 10 ? "%.0fK" : "%.1fK", value)
        } else {
            count = "\(reviewCount)"
        }
        return String(format: "%.1f  (%@)", rating, count)
    }
}
