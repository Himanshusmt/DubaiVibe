import Foundation

enum VenueDetailTab: String, CaseIterable, Hashable {
    case about
    case menu
    case vibes
    case deals
    case reviews

    var title: String {
        switch self {
        case .about: return L10n.about
        case .menu: return L10n.menu
        case .vibes: return L10n.vibes
        case .deals: return L10n.deals
        case .reviews: return L10n.reviews
        }
    }
}

struct DealTerm: Hashable {
    let symbolName: String
    let text: String
}

struct VenueDetailDeal: Hashable {
    let badge: String
    let discount: String
    let detail: String
    let terms: [DealTerm]
    let ctaTitle: String
}

struct VenueDetail: Hashable {
    let venueID: UUID
    let name: String
    let wordmark: String
    let cuisine: String
    let neighborhood: String
    let rating: Double
    let reviewCount: Int
    let isVerified: Bool
    let artworkStyle: ArtworkStyle
    let photoCount: Int
    let address: String
    let hoursText: String
    let phone: String
    let website: String
    let instagram: String
    let deal: VenueDetailDeal?
    let aboutText: String
    let defaultTab: VenueDetailTab
    var imageURL: String? = nil

    var subtitle: String { "\(cuisine)  •  \(neighborhood)" }

    var ratingValueText: String { String(format: "%.1f", rating) }

    var reviewCountText: String {
        if reviewCount >= 1000 {
            let value = Double(reviewCount) / 1000.0
            return String(format: value >= 10 ? "(%.0fK)" : "(%.1fK)", value)
        }
        return "(\(reviewCount))"
    }

    var photoCountText: String { L10n.photosCount(photoCount) }
}
