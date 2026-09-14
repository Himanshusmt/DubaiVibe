import Foundation

/// Demo gallery assets for venue photo screens until media API is wired.
enum VenueDemoPhotos {
    static let count = 30
    static let heroCount = 5

    /// Fixed picsum seeds — reliable demo loads (no broken hotlinks).
    private static let seeds: [String] = [
        "dubai-restaurant-01", "dubai-restaurant-02", "dubai-restaurant-03",
        "dubai-restaurant-04", "dubai-restaurant-05", "dubai-restaurant-06",
        "dubai-restaurant-07", "dubai-restaurant-08", "dubai-restaurant-09",
        "dubai-restaurant-10", "dubai-dining-11", "dubai-dining-12",
        "dubai-dining-13", "dubai-dining-14", "dubai-dining-15",
        "dubai-dining-16", "dubai-dining-17", "dubai-dining-18",
        "dubai-food-19", "dubai-food-20", "dubai-food-21",
        "dubai-food-22", "dubai-food-23", "dubai-food-24",
        "dubai-food-25", "dubai-food-26", "dubai-nightlife-27",
        "dubai-nightlife-28", "dubai-nightlife-29", "dubai-nightlife-30"
    ]

    /// Known-stable Unsplash CDN food / restaurant photos (direct images.unsplash.com).
    private static let rawURLs: [String] = [
        "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1550966871-3ed3cdb5ed0c?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1482049016688-2d3e1b311543?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1565958011703-44f9829ba187?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1484723091739-30a097e8f929?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1499028344343-cd173ffc68a9?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1432139555190-58524dae6a55?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1563379926898-05f4575a45d8?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1516684669134-de6f7c473a2a?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1473093295043-cdd812d0e601?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1504754524776-8f4f46914501?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1559339352-11d035aa65de?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1578474846511-969203411394?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1600891964599-f539ba4754dd?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1514933651103-005eec06c04b?auto=format&fit=crop&w=900&h=900&q=80",
        "https://images.unsplash.com/photo-1551218808-94e220e084d2?auto=format&fit=crop&w=900&h=900&q=80"
    ]

    static var demoURLs: [URL] {
        // Prefer stable picsum seeds so every cell always resolves.
        // Fallback list kept for future API wiring / local overrides.
        let picsum = seeds.prefix(count).compactMap { seed -> URL? in
            URL(string: "https://picsum.photos/seed/\(seed)/900/900")
        }
        if picsum.count == count { return Array(picsum) }
        return Array(rawURLs.compactMap(URL.init(string:)).prefix(count))
    }

    /// Landscape hero frames for the venue detail pager (minimum 5).
    static var heroURLs: [URL] {
        let picsum = seeds.prefix(heroCount).compactMap { seed -> URL? in
            URL(string: "https://picsum.photos/seed/\(seed)/1200/700")
        }
        if picsum.count == heroCount { return Array(picsum) }
        return Array(rawURLs.compactMap(URL.init(string:)).prefix(heroCount))
    }
}
