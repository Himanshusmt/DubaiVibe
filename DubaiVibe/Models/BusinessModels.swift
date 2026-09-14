import Foundation

// MARK: - Mobile Businesses (`GET /api/mobile/v1/businesses`) 

struct BusinessListResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: BusinessListData?

    enum CodingKeys: String, CodingKey {
        case success, message, data, items
        case nextCursor, next_cursor
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        if let nested = try? values.decode(BusinessListData.self, forKey: .data) {
            data = nested
        } else if let items = try? values.decode([BusinessItem].self, forKey: .items) {
            let cursor: String? = values.decodeFlexibleIfPresent(forKey: .nextCursor)
                ?? values.decodeFlexibleIfPresent(forKey: .next_cursor)
            data = BusinessListData(items: items, nextCursor: cursor)
        } else {
            data = try? values.decode(BusinessListData.self, forKey: .data)
        }
    }

    var items: [BusinessItem] { data?.items ?? [] }
    var nextCursor: String? { data?.nextCursor }
}

struct BusinessDetailResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: BusinessItem?

    enum CodingKeys: String, CodingKey {
        case success, message, data, business
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        if let nested = try? values.decode(BusinessItem.self, forKey: .data) {
            data = nested
        } else if let nested = try? values.decode(BusinessItem.self, forKey: .business) {
            data = nested
        } else if let wrapper = try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data),
                  let nested = try? wrapper.decode(BusinessItem.self, forKey: .business) {
            data = nested
        } else {
            data = nil
        }
    }

    var business: BusinessItem? { data }
}

struct BusinessListData: Decodable {
    let items: [BusinessItem]
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case items, results, businesses
        case nextCursor, next_cursor
    }

    init(items: [BusinessItem], nextCursor: String?) {
        self.items = items
        self.nextCursor = nextCursor
    }

    init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            items = (try? values.decode([BusinessItem].self, forKey: .items))
                ?? (try? values.decode([BusinessItem].self, forKey: .results))
                ?? (try? values.decode([BusinessItem].self, forKey: .businesses))
                ?? []
            nextCursor = values.decodeFlexibleIfPresent(forKey: .nextCursor)
                ?? values.decodeFlexibleIfPresent(forKey: .next_cursor)
            return
        }

        items = (try? decoder.singleValueContainer().decode([BusinessItem].self)) ?? []
        nextCursor = nil
    }
}

struct BusinessMedia: Decodable {
    let id: String?
    let url: String?
    let src: String?
    let path: String?
    let thumbnail: String?
    let downloadURL: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, url, src, path, thumbnail
        case downloadURL, downloadUrl, download_url
        case imageURL, imageUrl, image_url
    }

    init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            id = values.decodeFlexibleIfPresent(forKey: .id)
                ?? values.decodeFlexibleIfPresent(forKey: .uuid)
            url = values.decodeFlexibleIfPresent(forKey: .url)
                ?? values.decodeFlexibleIfPresent(forKey: .imageURL)
                ?? values.decodeFlexibleIfPresent(forKey: .imageUrl)
                ?? values.decodeFlexibleIfPresent(forKey: .image_url)
            src = values.decodeFlexibleIfPresent(forKey: .src)
            path = values.decodeFlexibleIfPresent(forKey: .path)
            thumbnail = values.decodeFlexibleIfPresent(forKey: .thumbnail)
            downloadURL = values.decodeFlexibleIfPresent(forKey: .downloadURL)
                ?? values.decodeFlexibleIfPresent(forKey: .downloadUrl)
                ?? values.decodeFlexibleIfPresent(forKey: .download_url)
            return
        }

        id = nil
        url = try? decoder.singleValueContainer().decode(String.self)
        src = nil
        path = nil
        thumbnail = nil
        downloadURL = nil
    }

    var resolvedURL: String? {
        [url, downloadURL, src, thumbnail, path]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
            ?? id.flatMap { raw in
                let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return nil }
                return APIEndpoint.baseURL + "media/\(trimmed)/download"
            }
    }
}

struct BusinessCategoryRef: Decodable {
    let id: String?
    let name: String?
    let slug: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, title, slug
    }

    init(id: String?, name: String?, slug: String?) {
        self.id = id
        self.name = name
        self.slug = slug
    }

    init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            id = values.decodeFlexibleIfPresent(forKey: .id)
                ?? values.decodeFlexibleIfPresent(forKey: .uuid)
            name = values.decodeFlexibleIfPresent(forKey: .name)
                ?? values.decodeFlexibleIfPresent(forKey: .title)
            slug = values.decodeFlexibleIfPresent(forKey: .slug)
            return
        }

        id = nil
        name = try? decoder.singleValueContainer().decode(String.self)
        slug = nil
    }
}

struct BusinessCoupon: Decodable {
    let title: String?
    let discount: String?
    let detail: String?
    let validity: String?
    let terms: [String]

    enum CodingKeys: String, CodingKey {
        case title, name, badge
        case discount, discountText, discount_text, value
        case detail, description, subtitle
        case validity, validUntil, valid_until, expiresAt, expires_at
        case terms, conditions
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = values.decodeFlexibleIfPresent(forKey: .title)
            ?? values.decodeFlexibleIfPresent(forKey: .name)
            ?? values.decodeFlexibleIfPresent(forKey: .badge)
        discount = values.decodeFlexibleIfPresent(forKey: .discount)
            ?? values.decodeFlexibleIfPresent(forKey: .discountText)
            ?? values.decodeFlexibleIfPresent(forKey: .discount_text)
            ?? values.decodeFlexibleIfPresent(forKey: .value)
        detail = values.decodeFlexibleIfPresent(forKey: .detail)
            ?? values.decodeFlexibleIfPresent(forKey: .description)
            ?? values.decodeFlexibleIfPresent(forKey: .subtitle)
        validity = values.decodeFlexibleIfPresent(forKey: .validity)
            ?? values.decodeFlexibleIfPresent(forKey: .validUntil)
            ?? values.decodeFlexibleIfPresent(forKey: .valid_until)
            ?? values.decodeFlexibleIfPresent(forKey: .expiresAt)
            ?? values.decodeFlexibleIfPresent(forKey: .expires_at)
        if let strings = (try? values.decode([String].self, forKey: .terms))
            ?? (try? values.decode([String].self, forKey: .conditions)) {
            terms = strings.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        } else if let objects = (try? values.decode([BusinessCouponTerm].self, forKey: .terms))
            ?? (try? values.decode([BusinessCouponTerm].self, forKey: .conditions)) {
            terms = objects.compactMap {
                $0.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            }.filter { !$0.isEmpty }
        } else {
            terms = []
        }
    }
}

struct BusinessCouponTerm: Decodable {
    let text: String?

    enum CodingKeys: String, CodingKey {
        case text, title, description, label
    }

    init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            text = values.decodeFlexibleIfPresent(forKey: .text)
                ?? values.decodeFlexibleIfPresent(forKey: .title)
                ?? values.decodeFlexibleIfPresent(forKey: .description)
                ?? values.decodeFlexibleIfPresent(forKey: .label)
            return
        }
        text = try? decoder.singleValueContainer().decode(String.self)
    }
}

struct BusinessHoursSlot: Decodable {
    let day: String?
    let open: String?
    let close: String?
    let label: String?

    enum CodingKeys: String, CodingKey {
        case day, dayOfWeek, day_of_week, weekday
        case open, openTime, open_time, from, start
        case close, closeTime, close_time, to, end
        case label, text, hours
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        day = values.decodeFlexibleIfPresent(forKey: .day)
            ?? values.decodeFlexibleIfPresent(forKey: .dayOfWeek)
            ?? values.decodeFlexibleIfPresent(forKey: .day_of_week)
            ?? values.decodeFlexibleIfPresent(forKey: .weekday)
        open = values.decodeFlexibleIfPresent(forKey: .open)
            ?? values.decodeFlexibleIfPresent(forKey: .openTime)
            ?? values.decodeFlexibleIfPresent(forKey: .open_time)
            ?? values.decodeFlexibleIfPresent(forKey: .from)
            ?? values.decodeFlexibleIfPresent(forKey: .start)
        close = values.decodeFlexibleIfPresent(forKey: .close)
            ?? values.decodeFlexibleIfPresent(forKey: .closeTime)
            ?? values.decodeFlexibleIfPresent(forKey: .close_time)
            ?? values.decodeFlexibleIfPresent(forKey: .to)
            ?? values.decodeFlexibleIfPresent(forKey: .end)
        label = values.decodeFlexibleIfPresent(forKey: .label)
            ?? values.decodeFlexibleIfPresent(forKey: .text)
            ?? values.decodeFlexibleIfPresent(forKey: .hours)
    }

    var displayText: String? {
        if let label, !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return label.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        let openText = open?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let closeText = close?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !openText.isEmpty, !closeText.isEmpty else { return nil }
        if let day, !day.isEmpty {
            return "\(day) \(openText) – \(closeText)"
        }
        return "Open \(openText) – \(closeText)"
    }
}

struct BusinessLocation: Decodable {
    let city: String?
    let neighborhood: String?
    let address: String?
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case city, neighborhood, area, address
        case latitude, lat, longitude, lng, lon
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        city = values.decodeFlexibleIfPresent(forKey: .city)
        neighborhood = values.decodeFlexibleIfPresent(forKey: .neighborhood)
            ?? values.decodeFlexibleIfPresent(forKey: .area)
        address = values.decodeFlexibleIfPresent(forKey: .address)
        latitude = values.decodeFlexibleIfPresent(forKey: .latitude)
            ?? values.decodeFlexibleIfPresent(forKey: .lat)
        longitude = values.decodeFlexibleIfPresent(forKey: .longitude)
            ?? values.decodeFlexibleIfPresent(forKey: .lng)
            ?? values.decodeFlexibleIfPresent(forKey: .lon)
    }
}

struct BusinessItem: Decodable {
    let id: String?
    let name: String?
    let cuisine: String?
    let category: BusinessCategoryRef?
    let city: String?
    let neighborhood: String?
    let address: String?
    let rating: Double?
    let reviewCount: Int?
    let isVerified: Bool?
    let imageURL: String?
    let photoCount: Int
    let phone: String?
    let website: String?
    let instagram: String?
    let about: String?
    let hoursText: String?
    let coupons: [BusinessCoupon]

    enum CodingKeys: String, CodingKey {
        case id, uuid, publicId, public_id
        case name, title, businessName, business_name
        case cuisine, type, cuisineType, cuisine_type
        case category, categoryName, category_name
        case city, neighborhood, area, address, fullAddress, full_address
        case rating, avgRating, averageRating, avg_rating, average_rating
        case reviewCount, reviewsCount, reviews_count, review_count, reviews
        case isVerified, is_verified, verified
        case coverImage, cover_image, coverImageUrl, cover_image_url, cover, coverUrl, cover_url
        case image, imageUrl, image_url, thumbnail, photo, photoUrl, photo_url
        case media, images
        case coupons, offers, deals
        case location
        case phone, phoneNumber, phone_number, contactPhone, contact_phone, tel
        case website, websiteUrl, website_url, url
        case instagram, instagramHandle, instagram_handle, instagramUrl, instagram_url
        case about, aboutText, about_text, description, bio
        case hours, hoursText, hours_text, openingHours, opening_hours, businessHours, business_hours
        case photoCount, photosCount, photo_count, photos_count
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
            ?? values.decodeFlexibleIfPresent(forKey: .uuid)
            ?? values.decodeFlexibleIfPresent(forKey: .publicId)
            ?? values.decodeFlexibleIfPresent(forKey: .public_id)
        name = values.decodeFlexibleIfPresent(forKey: .name)
            ?? values.decodeFlexibleIfPresent(forKey: .title)
            ?? values.decodeFlexibleIfPresent(forKey: .businessName)
            ?? values.decodeFlexibleIfPresent(forKey: .business_name)

        cuisine = values.decodeFlexibleIfPresent(forKey: .cuisine)
            ?? values.decodeFlexibleIfPresent(forKey: .type)
            ?? values.decodeFlexibleIfPresent(forKey: .cuisineType)
            ?? values.decodeFlexibleIfPresent(forKey: .cuisine_type)

        if let nested = try? values.decode(BusinessCategoryRef.self, forKey: .category) {
            category = nested
        } else if let categoryName: String = values.decodeFlexibleIfPresent(forKey: .category)
            ?? values.decodeFlexibleIfPresent(forKey: .categoryName)
            ?? values.decodeFlexibleIfPresent(forKey: .category_name) {
            category = BusinessCategoryRef(id: nil, name: categoryName, slug: nil)
        } else {
            category = nil
        }

        let location = try? values.decode(BusinessLocation.self, forKey: .location)
        city = values.decodeFlexibleIfPresent(forKey: .city) ?? location?.city
        neighborhood = values.decodeFlexibleIfPresent(forKey: .neighborhood)
            ?? values.decodeFlexibleIfPresent(forKey: .area)
            ?? location?.neighborhood
        address = values.decodeFlexibleIfPresent(forKey: .address)
            ?? values.decodeFlexibleIfPresent(forKey: .fullAddress)
            ?? values.decodeFlexibleIfPresent(forKey: .full_address)
            ?? location?.address

        rating = values.decodeFlexibleIfPresent(forKey: .rating)
            ?? values.decodeFlexibleIfPresent(forKey: .avgRating)
            ?? values.decodeFlexibleIfPresent(forKey: .averageRating)
            ?? values.decodeFlexibleIfPresent(forKey: .avg_rating)
            ?? values.decodeFlexibleIfPresent(forKey: .average_rating)

        if let count: Int = values.decodeFlexibleIfPresent(forKey: .reviewCount)
            ?? values.decodeFlexibleIfPresent(forKey: .reviewsCount)
            ?? values.decodeFlexibleIfPresent(forKey: .reviews_count)
            ?? values.decodeFlexibleIfPresent(forKey: .review_count)
            ?? values.decodeFlexibleIfPresent(forKey: .reviews) {
            reviewCount = count
        } else {
            reviewCount = nil
        }

        isVerified = values.decodeFlexibleIfPresent(forKey: .isVerified)
            ?? values.decodeFlexibleIfPresent(forKey: .is_verified)
            ?? values.decodeFlexibleIfPresent(forKey: .verified)

        let mediaItems = (try? values.decode([BusinessMedia].self, forKey: .media))
            ?? (try? values.decode([BusinessMedia].self, forKey: .images))
            ?? []
        let coverKeys: [CodingKeys] = [
            .coverImage, .cover_image, .coverImageUrl, .cover_image_url,
            .cover, .coverUrl, .cover_url,
            .image, .imageUrl, .image_url, .thumbnail, .photo, .photoUrl, .photo_url
        ]
        var resolvedImage: String?
        for key in coverKeys {
            if let url = Self.mediaURL(from: values, key: key) {
                resolvedImage = url
                break
            }
        }
        imageURL = resolvedImage ?? mediaItems.compactMap(\.resolvedURL).first
        photoCount = values.decodeFlexibleIfPresent(forKey: .photoCount)
            ?? values.decodeFlexibleIfPresent(forKey: .photosCount)
            ?? values.decodeFlexibleIfPresent(forKey: .photo_count)
            ?? values.decodeFlexibleIfPresent(forKey: .photos_count)
            ?? mediaItems.count

        coupons = (try? values.decode([BusinessCoupon].self, forKey: .coupons))
            ?? (try? values.decode([BusinessCoupon].self, forKey: .offers))
            ?? (try? values.decode([BusinessCoupon].self, forKey: .deals))
            ?? []

        phone = values.decodeFlexibleIfPresent(forKey: .phone)
            ?? values.decodeFlexibleIfPresent(forKey: .phoneNumber)
            ?? values.decodeFlexibleIfPresent(forKey: .phone_number)
            ?? values.decodeFlexibleIfPresent(forKey: .contactPhone)
            ?? values.decodeFlexibleIfPresent(forKey: .contact_phone)
            ?? values.decodeFlexibleIfPresent(forKey: .tel)
        website = values.decodeFlexibleIfPresent(forKey: .website)
            ?? values.decodeFlexibleIfPresent(forKey: .websiteUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .website_url)
        instagram = Self.normalizedInstagram(
            values.decodeFlexibleIfPresent(forKey: .instagram)
                ?? values.decodeFlexibleIfPresent(forKey: .instagramHandle)
                ?? values.decodeFlexibleIfPresent(forKey: .instagram_handle)
                ?? values.decodeFlexibleIfPresent(forKey: .instagramUrl)
                ?? values.decodeFlexibleIfPresent(forKey: .instagram_url)
        )
        about = values.decodeFlexibleIfPresent(forKey: .about)
            ?? values.decodeFlexibleIfPresent(forKey: .aboutText)
            ?? values.decodeFlexibleIfPresent(forKey: .about_text)
            ?? values.decodeFlexibleIfPresent(forKey: .description)
            ?? values.decodeFlexibleIfPresent(forKey: .bio)
        hoursText = Self.decodeHours(from: values)
    }

    func asVenue() -> Venue? {
        let resolvedName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !resolvedName.isEmpty else { return nil }

        let mappedCategory = VenueCategory.from(apiName: category?.name ?? category?.slug ?? cuisine)
        let cuisineText = (cuisine?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
            ?? (category?.name?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
            ?? mappedCategory.title
        let area = (neighborhood?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
            ?? (city?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
            ?? "Dubai"

        return Venue(
            id: Self.stableID(from: id, name: resolvedName),
            name: resolvedName,
            wordmark: Self.wordmark(from: resolvedName),
            category: mappedCategory,
            cuisine: cuisineText,
            neighborhood: area,
            rating: rating ?? 0,
            reviewCount: reviewCount ?? 0,
            deal: Self.deal(from: coupons.first),
            isFavorite: false,
            isBookmarked: false,
            isVerified: isVerified ?? false,
            artworkStyle: mappedCategory.artworkStyle,
            imageURL: imageURL,
            businessID: id?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        )
    }

    func asVenueDetail() -> VenueDetail? {
        guard let venue = asVenue() else { return nil }
        let area = venue.neighborhood
        let resolvedAddress = firstNonEmpty(address, "\(area), Dubai") ?? "Dubai"
        let resolvedAbout = firstNonEmpty(about) ?? "Discover \(venue.name) in \(area)."
        return VenueDetail(
            venueID: venue.id,
            name: venue.name,
            wordmark: venue.wordmark,
            cuisine: venue.cuisine,
            neighborhood: area,
            rating: venue.rating,
            reviewCount: venue.reviewCount,
            isVerified: venue.isVerified,
            artworkStyle: venue.artworkStyle,
            photoCount: max(photoCount, imageURL == nil ? 0 : 1),
            address: resolvedAddress,
            hoursText: firstNonEmpty(hoursText) ?? "Hours unavailable",
            phone: firstNonEmpty(phone) ?? "",
            website: firstNonEmpty(website) ?? "",
            instagram: firstNonEmpty(instagram) ?? "",
            deal: Self.detailDeal(from: coupons.first),
            aboutText: resolvedAbout,
            defaultTab: coupons.isEmpty ? .about : .deals,
            imageURL: imageURL
        )
    }

    private static func mediaURL(from values: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> String? {
        if let url: String = values.decodeFlexibleIfPresent(forKey: key) {
            let trimmed = url.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty { return trimmed }
        }
        if let media = try? values.decode(BusinessMedia.self, forKey: key) {
            return media.resolvedURL
        }
        if let media = try? values.decode([BusinessMedia].self, forKey: key) {
            return media.compactMap(\.resolvedURL).first
        }
        return nil
    }

    private static func stableID(from raw: String?, name: String) -> UUID {
        if let raw, let uuid = UUID(uuidString: raw.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return uuid
        }
        let seed = (raw?.isEmpty == false ? raw! : name)
        var bytes = [UInt8](repeating: 0, count: 16)
        for (index, byte) in Array(seed.utf8).enumerated() {
            bytes[index % 16] ^= byte
        }
        return UUID(uuid: (
            bytes[0], bytes[1], bytes[2], bytes[3],
            bytes[4], bytes[5], bytes[6], bytes[7],
            bytes[8], bytes[9], bytes[10], bytes[11],
            bytes[12], bytes[13], bytes[14], bytes[15]
        ))
    }

    private static func wordmark(from name: String) -> String {
        name.split(separator: " ").first.map(String.init)?.uppercased() ?? name.uppercased()
    }

    private static func deal(from coupon: BusinessCoupon?) -> Deal? {
        guard let coupon else { return nil }
        let discount = formattedDiscount(coupon.discount) ?? coupon.title
        guard let discount, !discount.isEmpty else { return nil }
        let detail = coupon.detail?.trimmingCharacters(in: .whitespacesAndNewlines)
        let validity = coupon.validity?.trimmingCharacters(in: .whitespacesAndNewlines)
        return Deal(
            discount: discount,
            detail: (detail?.isEmpty == false ? detail : nil) ?? "Your total bill",
            validity: (validity?.isEmpty == false ? validity : nil) ?? ""
        )
    }

    private static func formattedDiscount(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let lowered = trimmed.lowercased()
        if lowered.contains("off") || trimmed.contains("%") { return trimmed }
        if Double(trimmed) != nil { return "\(trimmed)% OFF" }
        return trimmed
    }

    private func firstNonEmpty(_ values: String?...) -> String? {
        values
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .first { !$0.isEmpty }
    }

    private static func decodeHours(from values: KeyedDecodingContainer<CodingKeys>) -> String? {
        let keys: [CodingKeys] = [
            .hoursText, .hours_text, .openingHours, .opening_hours, .businessHours, .business_hours, .hours
        ]
        for key in keys {
            if let text: String = values.decodeFlexibleIfPresent(forKey: key) {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { return trimmed }
            }
        }
        for key in keys {
            if let slots = try? values.decode([BusinessHoursSlot].self, forKey: key) {
                let formatted = slots.compactMap(\.displayText)
                if let first = formatted.first { return first }
            }
        }
        return nil
    }

    private static func normalizedInstagram(_ raw: String?) -> String? {
        guard var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !value.isEmpty else {
            return nil
        }
        if let url = URL(string: value), let host = url.host, host.contains("instagram.com") {
            value = url.path.split(separator: "/").first.map(String.init) ?? value
        }
        return value.trimmingCharacters(in: CharacterSet(charactersIn: "@/"))
    }

    private static func detailDeal(from coupon: BusinessCoupon?) -> VenueDetailDeal? {
        guard let listDeal = deal(from: coupon), let coupon else { return nil }
        let termTexts = coupon.terms
        let terms: [DealTerm]
        if termTexts.isEmpty {
            let validity = coupon.validity?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            terms = [
                DealTerm(symbolName: "calendar", text: validity.isEmpty ? "Limited time offer" : "Valid \(validity)"),
                DealTerm(symbolName: "person", text: "Dubai Vibe members only."),
                DealTerm(symbolName: "fork.knife", text: "Dine-in only"),
                DealTerm(symbolName: "nosign", text: "Cannot be combined with other offers")
            ]
        } else {
            let icons = ["calendar", "person", "fork.knife", "nosign"]
            terms = termTexts.enumerated().map { index, text in
                DealTerm(symbolName: icons[index % icons.count], text: text)
            }
        }
        return VenueDetailDeal(
            badge: firstNonEmptyStatic(coupon.title) ?? Deal.exclusiveBadge,
            discount: listDeal.discount,
            detail: listDeal.detail,
            terms: terms,
            ctaTitle: "Unlock Deal"
        )
    }

    private static func firstNonEmptyStatic(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension VenueCategory {
    static func from(apiName: String?) -> VenueCategory {
        let value = (apiName ?? "").lowercased()
        if value.contains("restaurant") || value.contains("food") || value.contains("dining") {
            return .restaurants
        }
        if value.contains("bar") || value.contains("lounge") {
            return .bars
        }
        if value.contains("night") || value.contains("club") {
            return .nightlife
        }
        if value.contains("cafe") || value.contains("café") || value.contains("coffee") {
            return .cafes
        }
        if value.contains("brunch") {
            return .brunches
        }
        if value.contains("beach") {
            return .beachClubs
        }
        if value.contains("ladies") {
            return .ladiesNights
        }
        if value.contains("gym") || value.contains("fitness") {
            return .gymsFitness
        }
        if value.contains("padel") || value.contains("tennis") {
            return .padelTennis
        }
        if value.contains("beauty") || value.contains("salon") {
            return .beautySalons
        }
        return .restaurants
    }

    var artworkStyle: ArtworkStyle {
        switch self {
        case .all: return .lounge
        case .restaurants: return .izakaya
        case .bars: return .lounge
        case .nightlife: return .club
        case .cafes: return .cafe
        case .brunches: return .brunch
        case .beachClubs: return .beach
        case .ladiesNights: return .club
        case .gymsFitness: return .wellness
        case .padelTennis: return .court
        case .beautySalons: return .salon
        }
    }
}
