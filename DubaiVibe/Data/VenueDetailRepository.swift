import Foundation

protocol VenueDetailRepositorying {
    func detail(for venueID: UUID) -> VenueDetail?
}

/// Static venue detail source. Swap for an API client later without changing the UI.
struct VenueDetailRepository: VenueDetailRepositorying {
    func detail(for venueID: UUID) -> VenueDetail? {
        Self.catalog[venueID] ?? Self.fallback(from: venueID)
    }

    private static let catalog: [UUID: VenueDetail] = {
        var map: [UUID: VenueDetail] = [:]
        for item in samples {
            map[item.venueID] = item
        }
        return map
    }()

    private static let samples: [VenueDetail] = [
        VenueDetail(
            venueID: UUID(uuidString: "11111111-1111-1111-1111-111111111111")!,
            name: "Zuma Dubai",
            wordmark: "zuma",
            cuisine: "Japanese",
            neighborhood: "DIFC",
            rating: 4.8,
            reviewCount: 2400,
            isVerified: true,
            artworkStyle: .zuma,
            photoCount: 120,
            address: "Gate Village 6, DIFC, Dubai",
            hoursText: "Open 12:00 – 00:00",
            phone: "+971 4 425 5660",
            website: "https://www.zumarestaurant.com",
            instagram: "zumadubai",
            deal: VenueDetailDeal(
                badge: "ONEVIBE EXCLUSIVE",
                discount: "15% OFF",
                detail: "Your total bill",
                terms: [
                    DealTerm(symbolName: "calendar", text: "Valid Sunday – Thursday"),
                    DealTerm(symbolName: "person", text: "OneVibe members only."),
                    DealTerm(symbolName: "fork.knife", text: "Dine-in only"),
                    DealTerm(symbolName: "nosign", text: "Cannot be combined with other offers")
                ],
                ctaTitle: "Unlock Deal"
            ),
            aboutText: "Contemporary Japanese cuisine in the heart of DIFC, with robata, sushi, and signature cocktails.",
            defaultTab: .deals
        ),
        VenueDetail(
            venueID: UUID(uuidString: "22222222-2222-2222-2222-222222222222")!,
            name: "CÉ LA VI Dubai",
            wordmark: "CÉ LA VI",
            cuisine: "International",
            neighborhood: "Downtown",
            rating: 4.7,
            reviewCount: 1800,
            isVerified: true,
            artworkStyle: .rooftop,
            photoCount: 86,
            address: "Address Downtown, Dubai",
            hoursText: "Open 18:00 – 03:00",
            phone: "+971 4 888 3444",
            website: "https://www.celavi.com",
            instagram: "celavidubai",
            deal: nil,
            aboutText: "Rooftop dining and nightlife with panoramic views of Downtown Dubai.",
            defaultTab: .about
        )
    ]

    /// Builds a sensible detail page for venues that don't have a hand-tuned entry yet.
    private static func fallback(from venueID: UUID) -> VenueDetail? {
        guard let venue = ExploreRepository().venues().first(where: { $0.id == venueID }) else {
            return nil
        }
        let detailDeal: VenueDetailDeal? = venue.deal.map { deal in
            VenueDetailDeal(
                badge: "ONEVIBE EXCLUSIVE",
                discount: deal.discount,
                detail: deal.detail,
                terms: [
                    DealTerm(symbolName: "calendar", text: "Valid \(deal.validity)"),
                    DealTerm(symbolName: "person", text: "OneVibe members only."),
                    DealTerm(symbolName: "fork.knife", text: "Dine-in only"),
                    DealTerm(symbolName: "nosign", text: "Cannot be combined with other offers")
                ],
                ctaTitle: "Unlock Deal"
            )
        }
        return VenueDetail(
            venueID: venue.id,
            name: venue.name,
            wordmark: venue.wordmark,
            cuisine: venue.cuisine,
            neighborhood: venue.neighborhood,
            rating: venue.rating,
            reviewCount: venue.reviewCount,
            isVerified: venue.isVerified,
            artworkStyle: venue.artworkStyle,
            photoCount: 48,
            address: "\(venue.neighborhood), Dubai",
            hoursText: "Open 12:00 – 00:00",
            phone: "+971 4 000 0000",
            website: "https://onevibe.ae",
            instagram: "onevibedubai",
            deal: detailDeal,
            aboutText: "Discover \(venue.name) in \(venue.neighborhood).",
            defaultTab: detailDeal == nil ? .about : .deals
        )
    }
}
