import Foundation
import UIKit

// MARK: - Mobile Categories (`GET /api/mobile/v1/categories`)

struct CategoryListResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: [CategoryItem]

    enum CodingKeys: String, CodingKey {
        case success, message, data, items, categories, results
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        if let items = try? values.decode([CategoryItem].self, forKey: .data) {
            data = items
        } else if let nested = try? values.decode(CategoryListData.self, forKey: .data) {
            data = nested.items
        } else if let items = try? values.decode([CategoryItem].self, forKey: .items) {
            data = items
        } else if let items = try? values.decode([CategoryItem].self, forKey: .categories) {
            data = items
        } else if let items = try? values.decode([CategoryItem].self, forKey: .results) {
            data = items
        } else {
            data = []
        }
    }

    var items: [CategoryItem] { data }
}

struct CategoryListData: Decodable {
    let items: [CategoryItem]

    enum CodingKeys: String, CodingKey {
        case items, results, categories
    }

    init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            items = (try? values.decode([CategoryItem].self, forKey: .items))
                ?? (try? values.decode([CategoryItem].self, forKey: .results))
                ?? (try? values.decode([CategoryItem].self, forKey: .categories))
                ?? []
            return
        }
        items = (try? decoder.singleValueContainer().decode([CategoryItem].self)) ?? []
    }
}

struct CategoryItem: Decodable {
    let id: String?
    let name: String?
    let slug: String?
    let description: String?
    let icon: String?
    let image: String?
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case id, uuid
        case name, title
        case slug
        case description
        case icon, iconURL, iconUrl, icon_url
        case image, imageURL, imageUrl, image_url
        case sortOrder, sort_order, order
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
            ?? values.decodeFlexibleIfPresent(forKey: .uuid)
        name = values.decodeFlexibleIfPresent(forKey: .name)
            ?? values.decodeFlexibleIfPresent(forKey: .title)
        slug = values.decodeFlexibleIfPresent(forKey: .slug)
        description = values.decodeFlexibleIfPresent(forKey: .description)
        icon = values.decodeFlexibleIfPresent(forKey: .icon)
            ?? values.decodeFlexibleIfPresent(forKey: .iconURL)
            ?? values.decodeFlexibleIfPresent(forKey: .iconUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .icon_url)
        image = values.decodeFlexibleIfPresent(forKey: .image)
            ?? values.decodeFlexibleIfPresent(forKey: .imageURL)
            ?? values.decodeFlexibleIfPresent(forKey: .imageUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .image_url)
        sortOrder = values.decodeFlexibleIfPresent(forKey: .sortOrder)
            ?? values.decodeFlexibleIfPresent(forKey: .sort_order)
            ?? values.decodeFlexibleIfPresent(forKey: .order)
    }

    func asExploreCategory() -> ExploreCategory? {
        let resolvedName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !resolvedName.isEmpty else { return nil }
        let resolvedID = id?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return ExploreCategory(
            id: resolvedID.isEmpty ? nil : resolvedID,
            name: resolvedName,
            slug: slug?.trimmingCharacters(in: .whitespacesAndNewlines),
            iconURL: Self.resolvedMediaURL(icon) ?? Self.resolvedMediaURL(image),
            sortOrder: sortOrder ?? 0
        )
    }

    private static func resolvedMediaURL(_ raw: String?) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return nil }
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return trimmed
        }
        if trimmed.hasPrefix("/"), let origin = APIEndpoint.origin {
            return origin + trimmed
        }
        if UUID(uuidString: trimmed) != nil {
            return APIEndpoint.baseURL + "media/\(trimmed)/download"
        }
        return trimmed
    }
}

struct ExploreCategory: Hashable {
    let id: String?
    let name: String
    let slug: String?
    let iconURL: String?
    let sortOrder: Int

    var isAll: Bool {
        let slugValue = (slug ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let nameValue = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return slugValue == "all" || nameValue == "all"
    }

    var title: String {
        isAll ? L10n.categoryAll : name
    }

    var hasIcon: Bool { iconURL != nil || localIcon != nil }

    var localIcon: UIImage? {
        guard !isAll else { return nil }
        // Prefer slug — API names like "Ladies Nights" can fuzzy-match the wrong category.
        return VenueCategory.matching(apiName: slug)?.icon
            ?? VenueCategory.matching(apiName: name)?.icon
    }

    static var all: ExploreCategory {
        ExploreCategory(id: nil, name: "All", slug: "all", iconURL: nil, sortOrder: -1)
    }

    static func == (lhs: ExploreCategory, rhs: ExploreCategory) -> Bool {
        if lhs.isAll && rhs.isAll { return true }
        guard let leftID = lhs.id, let rightID = rhs.id else { return false }
        return leftID == rightID
    }

    func hash(into hasher: inout Hasher) {
        if isAll {
            hasher.combine("all")
        } else {
            hasher.combine(id)
        }
    }
}

private extension APIEndpoint {
    static var origin: String? {
        guard let url = URL(string: baseURL), let host = url.host else { return nil }
        let scheme = url.scheme ?? "http"
        if let port = url.port {
            return "\(scheme)://\(host):\(port)"
        }
        return "\(scheme)://\(host)"
    }
}

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
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, title, slug, icon
        case iconURL, iconUrl, icon_url
    }

    init(id: String?, name: String?, slug: String?, icon: String? = nil) {
        self.id = id
        self.name = name
        self.slug = slug
        self.icon = icon
    }

    init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            id = values.decodeFlexibleIfPresent(forKey: .id)
                ?? values.decodeFlexibleIfPresent(forKey: .uuid)
            name = values.decodeFlexibleIfPresent(forKey: .name)
                ?? values.decodeFlexibleIfPresent(forKey: .title)
            slug = values.decodeFlexibleIfPresent(forKey: .slug)
            icon = values.decodeFlexibleIfPresent(forKey: .icon)
                ?? values.decodeFlexibleIfPresent(forKey: .iconURL)
                ?? values.decodeFlexibleIfPresent(forKey: .iconUrl)
                ?? values.decodeFlexibleIfPresent(forKey: .icon_url)
            return
        }

        id = nil
        name = try? decoder.singleValueContainer().decode(String.self)
        slug = nil
        icon = nil
    }
}

struct BusinessLinks: Decodable {
    let website: String?
    let onevibe: String?
    let instagram: String?

    enum CodingKeys: String, CodingKey {
        case website, onevibe, instagram
        case websiteUrl, website_url, url
        case instagramHandle, instagram_handle, instagramUrl, instagram_url
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        website = values.decodeFlexibleIfPresent(forKey: .website)
            ?? values.decodeFlexibleIfPresent(forKey: .websiteUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .website_url)
            ?? values.decodeFlexibleIfPresent(forKey: .url)
        onevibe = values.decodeFlexibleIfPresent(forKey: .onevibe)
        instagram = values.decodeFlexibleIfPresent(forKey: .instagram)
            ?? values.decodeFlexibleIfPresent(forKey: .instagramHandle)
            ?? values.decodeFlexibleIfPresent(forKey: .instagram_handle)
            ?? values.decodeFlexibleIfPresent(forKey: .instagramUrl)
            ?? values.decodeFlexibleIfPresent(forKey: .instagram_url)
    }
}

struct BusinessRating: Decodable {
    let average: Double?
    let count: Int?

    enum CodingKeys: String, CodingKey {
        case average, avg, value, rating, score
        case count, reviews, reviewCount, reviewsCount, review_count, reviews_count
    }

    init(from decoder: Decoder) throws {
        if let values = try? decoder.container(keyedBy: CodingKeys.self) {
            average = values.decodeFlexibleIfPresent(forKey: .average)
                ?? values.decodeFlexibleIfPresent(forKey: .avg)
                ?? values.decodeFlexibleIfPresent(forKey: .value)
                ?? values.decodeFlexibleIfPresent(forKey: .rating)
                ?? values.decodeFlexibleIfPresent(forKey: .score)
            count = values.decodeFlexibleIfPresent(forKey: .count)
                ?? values.decodeFlexibleIfPresent(forKey: .reviews)
                ?? values.decodeFlexibleIfPresent(forKey: .reviewCount)
                ?? values.decodeFlexibleIfPresent(forKey: .reviewsCount)
                ?? values.decodeFlexibleIfPresent(forKey: .review_count)
                ?? values.decodeFlexibleIfPresent(forKey: .reviews_count)
            return
        }

        average = try? decoder.singleValueContainer().decode(Double.self)
        count = nil
    }
}

struct BusinessWorkingHoursPeriod: Decodable {
    let is24Hours: Bool?
    let openDay: String?
    let closeDay: String?
    let openTime: String?
    let closeTime: String?

    enum CodingKeys: String, CodingKey {
        case is24Hours, is_24_hours, is24Hour
        case openDay, open_day, day, dayOfWeek, day_of_week, weekday
        case closeDay, close_day
        case openTime, open_time, open, from, start
        case closeTime, close_time, close, to, end
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        is24Hours = values.decodeFlexibleIfPresent(forKey: .is24Hours)
            ?? values.decodeFlexibleIfPresent(forKey: .is_24_hours)
            ?? values.decodeFlexibleIfPresent(forKey: .is24Hour)
        openDay = values.decodeFlexibleIfPresent(forKey: .openDay)
            ?? values.decodeFlexibleIfPresent(forKey: .open_day)
            ?? values.decodeFlexibleIfPresent(forKey: .day)
            ?? values.decodeFlexibleIfPresent(forKey: .dayOfWeek)
            ?? values.decodeFlexibleIfPresent(forKey: .day_of_week)
            ?? values.decodeFlexibleIfPresent(forKey: .weekday)
        closeDay = values.decodeFlexibleIfPresent(forKey: .closeDay)
            ?? values.decodeFlexibleIfPresent(forKey: .close_day)
        openTime = values.decodeFlexibleIfPresent(forKey: .openTime)
            ?? values.decodeFlexibleIfPresent(forKey: .open_time)
            ?? values.decodeFlexibleIfPresent(forKey: .open)
            ?? values.decodeFlexibleIfPresent(forKey: .from)
            ?? values.decodeFlexibleIfPresent(forKey: .start)
        closeTime = values.decodeFlexibleIfPresent(forKey: .closeTime)
            ?? values.decodeFlexibleIfPresent(forKey: .close_time)
            ?? values.decodeFlexibleIfPresent(forKey: .close)
            ?? values.decodeFlexibleIfPresent(forKey: .to)
            ?? values.decodeFlexibleIfPresent(forKey: .end)
    }
}

struct BusinessWorkingHours: Decodable {
    let timezone: String?
    let specialHours: [BusinessWorkingHoursPeriod]
    let periods: [BusinessWorkingHoursPeriod]
    let openNow: Bool?
    let weekdayText: [String]

    enum CodingKeys: String, CodingKey {
        case timezone, timeZone, time_zone
        case specialHours, special_hours
        case periods
        case openNow, open_now, isOpen, is_open
        case weekdayText, weekday_text
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        timezone = values.decodeFlexibleIfPresent(forKey: .timezone)
            ?? values.decodeFlexibleIfPresent(forKey: .timeZone)
            ?? values.decodeFlexibleIfPresent(forKey: .time_zone)
        specialHours = (try? values.decode([BusinessWorkingHoursPeriod].self, forKey: .specialHours))
            ?? (try? values.decode([BusinessWorkingHoursPeriod].self, forKey: .special_hours))
            ?? []
        periods = (try? values.decode([BusinessWorkingHoursPeriod].self, forKey: .periods)) ?? []
        openNow = values.decodeFlexibleIfPresent(forKey: .openNow)
            ?? values.decodeFlexibleIfPresent(forKey: .open_now)
            ?? values.decodeFlexibleIfPresent(forKey: .isOpen)
            ?? values.decodeFlexibleIfPresent(forKey: .is_open)
        weekdayText = ((try? values.decode([String].self, forKey: .weekdayText))
            ?? (try? values.decode([String].self, forKey: .weekday_text))
            ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    var displayText: String? {
        if let first = weekdayText.first, !first.isEmpty {
            return weekdayText.joined(separator: "\n")
        }
        let formatted = periods.compactMap { period -> String? in
            let open = period.openTime?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let close = period.closeTime?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !open.isEmpty, !close.isEmpty else { return nil }
            if let day = period.openDay, !day.isEmpty {
                return "\(day.capitalized) \(open) – \(close)"
            }
            return "Open \(open) – \(close)"
        }
        return formatted.isEmpty ? nil : formatted.joined(separator: "\n")
    }

    /// Compact one-line status for the detail meta card (e.g. "Open now · 9:00 AM – 11:00 PM").
    var summaryText: String? {
        let today = Self.currentWeekdayName(timezone: timezone)
        let period = periods.first {
            ($0.openDay ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == today
        }
        let openDisplay = Self.formatClock(period?.openTime)
        let closeDisplay = Self.formatClock(period?.closeTime)

        if openNow == true {
            if let openDisplay, let closeDisplay {
                return "Open now · \(openDisplay) – \(closeDisplay)"
            }
            if let closeDisplay { return "Open now · Closes \(closeDisplay)" }
            return "Open now"
        }
        if openNow == false {
            if let openDisplay { return "Closed · Opens \(openDisplay)" }
            return "Closed"
        }
        if let openDisplay, let closeDisplay {
            return "\(openDisplay) – \(closeDisplay)"
        }
        if let line = weekdayText.first(where: {
            $0.lowercased().hasPrefix(today)
        }) ?? weekdayText.first {
            return line
        }
        return displayText?.components(separatedBy: "\n").first
    }

    private static func currentWeekdayName(timezone: String?) -> String {
        var calendar = Calendar(identifier: .gregorian)
        if let timezone, let tz = TimeZone(identifier: timezone) {
            calendar.timeZone = tz
        }
        let names = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        let weekday = calendar.component(.weekday, from: Date()) // 1 = Sunday
        return names[(weekday - 1 + names.count) % names.count]
    }

    private static func formatClock(_ raw: String?) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return nil }
        let parts = trimmed.split(separator: ":")
        guard let hourPart = parts.first, let hour24 = Int(hourPart) else { return trimmed }
        let minute = parts.count > 1 ? String(parts[1].prefix(2)) : "00"
        let period = hour24 >= 12 ? "PM" : "AM"
        let hour12: Int
        switch hour24 % 12 {
        case 0: hour12 = 12
        default: hour12 = hour24 % 12
        }
        return "\(hour12):\(minute) \(period)"
    }
}

struct BusinessCouponValidity: Decodable {
    let label: String?
    let expiresAt: String?
    let type: String?
    let days: [String]
    let startsAt: String?

    enum CodingKeys: String, CodingKey {
        case label, text
        case expiresAt, expires_at, validUntil, valid_until
        case type
        case days, daysOfWeek, days_of_week
        case startsAt, starts_at, validFrom, valid_from
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        label = values.decodeFlexibleIfPresent(forKey: .label)
            ?? values.decodeFlexibleIfPresent(forKey: .text)
        expiresAt = values.decodeFlexibleIfPresent(forKey: .expiresAt)
            ?? values.decodeFlexibleIfPresent(forKey: .expires_at)
            ?? values.decodeFlexibleIfPresent(forKey: .validUntil)
            ?? values.decodeFlexibleIfPresent(forKey: .valid_until)
        type = values.decodeFlexibleIfPresent(forKey: .type)
        days = ((try? values.decode([String].self, forKey: .days))
            ?? (try? values.decode([String].self, forKey: .daysOfWeek))
            ?? (try? values.decode([String].self, forKey: .days_of_week))
            ?? [])
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        startsAt = values.decodeFlexibleIfPresent(forKey: .startsAt)
            ?? values.decodeFlexibleIfPresent(forKey: .starts_at)
            ?? values.decodeFlexibleIfPresent(forKey: .validFrom)
            ?? values.decodeFlexibleIfPresent(forKey: .valid_from)
    }
}

struct BusinessCoupon: Decodable {
    let id: String?
    let title: String?
    let discount: String?
    let offer: String?
    let detail: String?
    let discountType: String?
    let discountValue: String?
    let validity: String?
    let validityInfo: BusinessCouponValidity?
    let terms: [String]

    enum CodingKeys: String, CodingKey {
        case id, uuid
        case title, name, badge
        case discount, discountText, discount_text, value
        case offer
        case detail, description, subtitle
        case discountType, discount_type
        case discountValue, discount_value
        case validity, validUntil, valid_until, expiresAt, expires_at
        case terms, conditions
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
            ?? values.decodeFlexibleIfPresent(forKey: .uuid)
        title = values.decodeFlexibleIfPresent(forKey: .title)
            ?? values.decodeFlexibleIfPresent(forKey: .name)
            ?? values.decodeFlexibleIfPresent(forKey: .badge)
        offer = values.decodeFlexibleIfPresent(forKey: .offer)
        discount = values.decodeFlexibleIfPresent(forKey: .discount)
            ?? values.decodeFlexibleIfPresent(forKey: .discountText)
            ?? values.decodeFlexibleIfPresent(forKey: .discount_text)
            ?? values.decodeFlexibleIfPresent(forKey: .value)
            ?? offer
        detail = values.decodeFlexibleIfPresent(forKey: .detail)
            ?? values.decodeFlexibleIfPresent(forKey: .description)
            ?? values.decodeFlexibleIfPresent(forKey: .subtitle)
        discountType = values.decodeFlexibleIfPresent(forKey: .discountType)
            ?? values.decodeFlexibleIfPresent(forKey: .discount_type)
        discountValue = values.decodeFlexibleIfPresent(forKey: .discountValue)
            ?? values.decodeFlexibleIfPresent(forKey: .discount_value)
        if let nested = try? values.decode(BusinessCouponValidity.self, forKey: .validity) {
            validityInfo = nested
            validity = nested.label
                ?? values.decodeFlexibleIfPresent(forKey: .validUntil)
                ?? values.decodeFlexibleIfPresent(forKey: .valid_until)
                ?? values.decodeFlexibleIfPresent(forKey: .expiresAt)
                ?? values.decodeFlexibleIfPresent(forKey: .expires_at)
        } else {
            validityInfo = nil
            validity = values.decodeFlexibleIfPresent(forKey: .validity)
                ?? values.decodeFlexibleIfPresent(forKey: .validUntil)
                ?? values.decodeFlexibleIfPresent(forKey: .valid_until)
                ?? values.decodeFlexibleIfPresent(forKey: .expiresAt)
                ?? values.decodeFlexibleIfPresent(forKey: .expires_at)
        }
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
        case day, dayOfWeek, day_of_week, weekday, openDay, open_day
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
            ?? values.decodeFlexibleIfPresent(forKey: .openDay)
            ?? values.decodeFlexibleIfPresent(forKey: .open_day)
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
    let type: String?
    let cuisine: String?
    let category: BusinessCategoryRef?
    let city: String?
    let neighborhood: String?
    let address: String?
    let pincode: String?
    let countryId: Int?
    let stateId: Int?
    let status: Int?
    let distanceMeters: Double?
    let latitude: Double?
    let longitude: Double?
    let rating: Double?
    let reviewCount: Int?
    let isVerified: Bool?
    let isFavorite: Bool?
    let isSaved: Bool?
    let imageURL: String?
    let coverImage: String?
    let banner: String?
    let logo: String?
    let photoCount: Int
    let phone: String?
    let website: String?
    let instagram: String?
    let links: BusinessLinks?
    let about: String?
    let workingHours: BusinessWorkingHours?
    let hoursText: String?
    let mediaURLs: [String]
    let coupons: [BusinessCoupon]

    enum CodingKeys: String, CodingKey {
        case id, uuid, publicId, public_id
        case name, title, businessName, business_name
        case cuisine, type, cuisineType, cuisine_type
        case category, categoryName, category_name
        case city, neighborhood, area, address, fullAddress, full_address
        case pincode, pinCode, pin_code, zip, zipcode, postalCode, postal_code
        case countryId, country_id
        case stateId, state_id
        case status
        case distanceMeters, distance_meters, distance
        case rating, avgRating, averageRating, avg_rating, average_rating
        case reviewCount, reviewsCount, reviews_count, review_count, reviews
        case isVerified, is_verified, verified
        case isFavorite, is_favorite, favorite
        case isSaved, is_saved, saved, isBookmarked, is_bookmarked, bookmarked
        case coverImage, cover_image, coverImageUrl, cover_image_url, cover, coverUrl, cover_url
        case image, imageUrl, image_url, thumbnail, photo, photoUrl, photo_url
        case banner, logo
        case media, images
        case coupon, coupons, offers, deals
        case location
        case links
        case phone, phoneNumber, phone_number, contactPhone, contact_phone, tel
        case website, websiteUrl, website_url, url
        case instagram, instagramHandle, instagram_handle, instagramUrl, instagram_url
        case about, aboutText, about_text, description, bio
        case workingHours, working_hours
        case hours, hoursText, hours_text, openingHours, opening_hours, businessHours, business_hours
        case photoCount, photosCount, photo_count, photos_count
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = Self.firstFlexible(from: values, keys: [.id, .uuid, .publicId, .public_id])
        name = Self.firstFlexible(from: values, keys: [.name, .title, .businessName, .business_name])
        type = Self.firstFlexible(from: values, keys: [.type])

        let rawCuisine: String? = Self.firstFlexible(
            from: values,
            keys: [.cuisine, .cuisineType, .cuisine_type]
        )
        cuisine = Self.resolvedCuisine(rawCuisine, type: type)

        if let nested = try? values.decode(BusinessCategoryRef.self, forKey: .category) {
            category = nested
        } else if let categoryName: String = Self.firstFlexible(
            from: values,
            keys: [.category, .categoryName, .category_name]
        ) {
            category = BusinessCategoryRef(id: nil, name: categoryName, slug: nil)
        } else {
            category = nil
        }

        let location = try? values.decode(BusinessLocation.self, forKey: .location)
        let decodedCity: String? = Self.firstFlexible(from: values, keys: [.city])
        city = decodedCity ?? location?.city

        let decodedNeighborhood: String? = Self.firstFlexible(from: values, keys: [.neighborhood, .area])
        neighborhood = decodedNeighborhood ?? location?.neighborhood

        let decodedAddress: String? = Self.firstFlexible(
            from: values,
            keys: [.address, .fullAddress, .full_address]
        )
        address = decodedAddress ?? location?.address

        pincode = Self.firstFlexible(
            from: values,
            keys: [.pincode, .pinCode, .pin_code, .zip, .zipcode, .postalCode, .postal_code]
        )
        countryId = Self.firstFlexible(from: values, keys: [.countryId, .country_id])
        stateId = Self.firstFlexible(from: values, keys: [.stateId, .state_id])
        status = Self.firstFlexible(from: values, keys: [.status])
        distanceMeters = Self.firstFlexible(
            from: values,
            keys: [.distanceMeters, .distance_meters, .distance]
        )
        latitude = location?.latitude
        longitude = location?.longitude

        let nestedRating = try? values.decode(BusinessRating.self, forKey: .rating)
        let decodedRating: Double? = Self.firstFlexible(
            from: values,
            keys: [.rating, .avgRating, .averageRating, .avg_rating, .average_rating]
        )
        rating = nestedRating?.average ?? decodedRating

        let decodedReviewCount: Int? = Self.firstFlexible(
            from: values,
            keys: [.reviewCount, .reviewsCount, .reviews_count, .review_count, .reviews]
        )
        reviewCount = decodedReviewCount ?? nestedRating?.count

        isVerified = Self.firstFlexible(from: values, keys: [.isVerified, .is_verified, .verified])
        isFavorite = Self.firstFlexible(from: values, keys: [.isFavorite, .is_favorite, .favorite])
        isSaved = Self.firstFlexible(
            from: values,
            keys: [.isSaved, .is_saved, .saved, .isBookmarked, .is_bookmarked, .bookmarked]
        )

        let mediaFromMedia = (try? values.decode([BusinessMedia].self, forKey: .media)) ?? []
        let mediaFromImages = (try? values.decode([BusinessMedia].self, forKey: .images)) ?? []
        let mediaItems = mediaFromMedia.isEmpty ? mediaFromImages : mediaFromMedia

        let coverKeys: [CodingKeys] = [
            .coverImage, .cover_image, .coverImageUrl, .cover_image_url,
            .cover, .coverUrl, .cover_url
        ]
        var decodedCover: String?
        for key in coverKeys {
            if let url = Self.mediaURL(from: values, key: key) {
                decodedCover = url
                break
            }
        }
        coverImage = decodedCover
        banner = Self.mediaURL(from: values, key: .banner)
        logo = Self.mediaURL(from: values, key: .logo)

        let resolvedMedia = mediaItems.compactMap(\.resolvedURL)
        mediaURLs = Self.uniqueURLs([coverImage, banner].compactMap { $0 } + resolvedMedia)
        // Explore hero uses cover image only — never the brand logo.
        imageURL = coverImage

        let decodedPhotoCount: Int? = Self.firstFlexible(
            from: values,
            keys: [.photoCount, .photosCount, .photo_count, .photos_count]
        )
        photoCount = decodedPhotoCount ?? max(mediaURLs.count, mediaItems.count)

        if let single = try? values.decode(BusinessCoupon.self, forKey: .coupon) {
            coupons = [single]
        } else {
            let fromCoupons = try? values.decode([BusinessCoupon].self, forKey: .coupons)
            let fromCoupon = try? values.decode([BusinessCoupon].self, forKey: .coupon)
            let fromOffers = try? values.decode([BusinessCoupon].self, forKey: .offers)
            let fromDeals = try? values.decode([BusinessCoupon].self, forKey: .deals)
            coupons = fromCoupons ?? fromCoupon ?? fromOffers ?? fromDeals ?? []
        }

        links = try? values.decode(BusinessLinks.self, forKey: .links)

        phone = Self.firstFlexible(
            from: values,
            keys: [.phone, .phoneNumber, .phone_number, .contactPhone, .contact_phone, .tel]
        )

        let decodedWebsite: String? = Self.firstFlexible(
            from: values,
            keys: [.website, .websiteUrl, .website_url]
        )
        website = decodedWebsite ?? links?.website

        let decodedInstagram: String? = Self.firstFlexible(
            from: values,
            keys: [.instagram, .instagramHandle, .instagram_handle, .instagramUrl, .instagram_url]
        )
        instagram = Self.normalizedInstagram(decodedInstagram ?? links?.instagram)

        about = Self.firstFlexible(
            from: values,
            keys: [.about, .aboutText, .about_text, .description, .bio]
        )

        workingHours = Self.decodeWorkingHours(from: values)
        hoursText = workingHours?.displayText ?? Self.decodeHours(from: values)
    }

    private static func firstFlexible<T: FlexibleDecodable>(
        from values: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) -> T? {
        for key in keys {
            if let value: T = values.decodeFlexibleIfPresent(forKey: key) {
                return value
            }
        }
        return nil
    }

    private static func uniqueURLs(_ candidates: [String]) -> [String] {
        var urls: [String] = []
        var seen = Set<String>()
        for candidate in candidates {
            guard let trimmed = sanitizedURLString(candidate), !seen.contains(trimmed) else { continue }
            seen.insert(trimmed)
            urls.append(trimmed)
        }
        return urls
    }

    private static func decodeWorkingHours(
        from values: KeyedDecodingContainer<CodingKeys>
    ) -> BusinessWorkingHours? {
        let keys: [CodingKeys] = [
            .workingHours, .working_hours,
            .openingHours, .opening_hours,
            .businessHours, .business_hours,
            .hours
        ]
        for key in keys {
            if let hours = try? values.decode(BusinessWorkingHours.self, forKey: key) {
                return hours
            }
        }
        return nil
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
            isFavorite: isFavorite ?? false,
            isBookmarked: isSaved ?? false,
            isVerified: isVerified ?? false,
            artworkStyle: mappedCategory.artworkStyle,
            imageURL: imageURL,
            businessID: id?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        )
    }

    func asVenueDetail() -> VenueDetail? {
        guard let venue = asVenue() else { return nil }
        let area = venue.neighborhood
        let resolvedAddress = Self.formattedAddress(street: address, city: city) ?? "Dubai"
        let resolvedAbout = firstNonEmpty(about) ?? "Discover \(venue.name) in \(area)."
        let fullHours = firstNonEmpty(hoursText) ?? "Hours unavailable"
        let summaryHours = firstNonEmpty(workingHours?.summaryText) ?? fullHours.components(separatedBy: "\n").first ?? fullHours
        return VenueDetail(
            venueID: venue.id,
            name: venue.name,
            wordmark: venue.wordmark,
            cuisine: venue.cuisine,
            neighborhood: area,
            rating: venue.rating,
            reviewCount: venue.reviewCount,
            isVerified: venue.isVerified,
            isFavorite: venue.isFavorite,
            artworkStyle: venue.artworkStyle,
            photoCount: {
                if !mediaURLs.isEmpty { return mediaURLs.count }
                return imageURL == nil ? 0 : 1
            }(),
            address: resolvedAddress,
            hoursText: summaryHours,
            hoursFullText: fullHours,
            weekdayHours: {
                let days = workingHours?.weekdayText ?? []
                if !days.isEmpty { return days }
                return fullHours
                    .components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }(),
            phone: firstNonEmpty(phone) ?? "",
            website: firstNonEmpty(website) ?? "",
            instagram: firstNonEmpty(instagram) ?? "",
            deal: Self.detailDeal(from: coupons.first),
            aboutText: resolvedAbout,
            defaultTab: coupons.isEmpty ? .about : .deals,
            imageURL: imageURL,
            logoURL: logo,
            mediaURLs: mediaURLs,
            latitude: latitude,
            longitude: longitude
        )
    }

    private static func formattedAddress(street: String?, city: String?) -> String? {
        let streetText = street?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cityText = city?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if streetText.isEmpty {
            return cityText.isEmpty ? nil : cityText
        }
        if cityText.isEmpty || streetText.localizedCaseInsensitiveContains(cityText) {
            return streetText
        }
        return "\(streetText), \(cityText)"
    }

    private static func mediaURL(from values: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) -> String? {
        if let url: String = values.decodeFlexibleIfPresent(forKey: key) {
            if let sanitized = sanitizedURLString(url) { return sanitized }
        }
        if let media = try? values.decode(BusinessMedia.self, forKey: key) {
            return sanitizedURLString(media.resolvedURL)
        }
        if let media = try? values.decode([BusinessMedia].self, forKey: key) {
            return media.compactMap { sanitizedURLString($0.resolvedURL) }.first
        }
        return nil
    }

    private static func sanitizedURLString(_ raw: String?) -> String? {
        var value = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !value.isEmpty else { return nil }
        value = value.replacingOccurrences(of: "\\/", with: "/")
        if value.hasPrefix("http://") || value.hasPrefix("https://") {
            return value
        }
        if value.hasPrefix("/"), let origin = APIEndpoint.origin {
            return origin + value
        }
        if UUID(uuidString: value) != nil {
            return APIEndpoint.baseURL + "media/\(value)/download"
        }
        return value
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
        let discount = cleanDiscount(coupon.offer)
            ?? cleanDiscount(coupon.discount)
            ?? formattedDiscount(coupon.discountValue)
            ?? cleanDiscount(coupon.title)
        guard let discount, !discount.isEmpty else { return nil }
        let detail = dealDetailText(from: coupon)
        let validity = formattedValidityDays(coupon.validityInfo?.days)
            ?? coupon.validityInfo?.label?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? formattedValidUntil(coupon.validityInfo?.expiresAt)
            ?? formattedValidUntil(coupon.validity)
            ?? coupon.validity?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? ""
        return Deal(
            discount: discount,
            detail: detail,
            validity: validity
        )
    }

    /// Turns API ISO dates (`2026-12-15T00:00:00.000Z`) into `Valid until 15 Dec 2026`.
    private static func formattedValidUntil(_ raw: String?) -> String? {
        let value = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !value.isEmpty else { return nil }
        guard let date = parseCouponISO8601(value) else { return nil }
        let formatter = DateFormatter()
        formatter.locale = LocalizationManager.shared.locale
        formatter.dateFormat = "d MMM yyyy"
        return "\(L10n.validUntil) \(formatter.string(from: date))"
    }

    private static func parseCouponISO8601(_ value: String) -> Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: value) { return date }
        let basic = ISO8601DateFormatter()
        basic.formatOptions = [.withInternetDateTime]
        return basic.date(from: value)
    }

    private static func dealDetailText(from coupon: BusinessCoupon) -> String {
        // Prefer full API title under the discount (e.g. "15% OFF ON TOTAL BILL").
        let title = coupon.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !title.isEmpty { return title }

        let description = coupon.detail?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !description.isEmpty,
           !description.localizedCaseInsensitiveContains("configure the headline") {
            return description
        }
        return "on total bill"
    }

    /// Formats API `days` into compact ranges: "Monday – Saturday", "Monday – Wednesday".
    /// Consecutive weekdays collapse to a start–end range; gaps stay comma-separated.
    private static func formattedValidityDays(_ days: [String]?) -> String? {
        guard let days, !days.isEmpty else { return nil }

        let order = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        let nameByIndex = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let aliases: [String: Int] = [
            "sun": 0, "sunday": 0,
            "mon": 1, "monday": 1,
            "tue": 2, "tues": 2, "tuesday": 2,
            "wed": 3, "wednesday": 3,
            "thu": 4, "thur": 4, "thurs": 4, "thursday": 4,
            "fri": 5, "friday": 5,
            "sat": 6, "saturday": 6
        ]

        var indices = Set<Int>()
        for raw in days {
            let key = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            if let index = aliases[key] ?? order.firstIndex(of: key) {
                indices.insert(index)
            }
        }
        guard !indices.isEmpty else { return nil }

        let sorted = indices.sorted()
        var ranges: [(Int, Int)] = []
        var start = sorted[0]
        var previous = sorted[0]
        for index in sorted.dropFirst() {
            if index == previous + 1 {
                previous = index
                continue
            }
            ranges.append((start, previous))
            start = index
            previous = index
        }
        ranges.append((start, previous))

        let parts = ranges.map { startIndex, endIndex -> String in
            let startName = nameByIndex[startIndex]
            if startIndex == endIndex { return startName }
            return "\(startName) – \(nameByIndex[endIndex])"
        }
        return parts.joined(separator: ", ")
    }

    private static func cleanDiscount(_ raw: String?) -> String? {
        guard let formatted = formattedDiscount(raw) else { return nil }
        var value = formatted
        while value.hasPrefix("-") {
            value = String(value.dropFirst()).trimmingCharacters(in: .whitespaces)
        }
        return value.isEmpty ? nil : value
    }

    private static func resolvedCuisine(_ raw: String?, type: String?) -> String? {
        let trimmed = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !trimmed.isEmpty { return trimmed }
        let typeValue = type?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let ignoredTypes: Set<String> = ["business", "venue", "place", "listing"]
        if !typeValue.isEmpty, !ignoredTypes.contains(typeValue.lowercased()) {
            return typeValue
        }
        return nil
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
            .workingHours, .working_hours,
            .hoursText, .hours_text, .openingHours, .opening_hours, .businessHours, .business_hours, .hours
        ]
        for key in keys {
            if let hours = try? values.decode(BusinessWorkingHours.self, forKey: key),
               let text = hours.displayText {
                return text
            }
            if let text: String = values.decodeFlexibleIfPresent(forKey: key) {
                let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { return trimmed }
            }
        }
        for key in keys {
            if let slots = try? values.decode([BusinessHoursSlot].self, forKey: key) {
                let formatted = slots.compactMap(\.displayText)
                if !formatted.isEmpty { return formatted.joined(separator: "\n") }
            }
            if let periods = try? values.decode([BusinessWorkingHoursPeriod].self, forKey: key) {
                let formatted = periods.compactMap { period -> String? in
                    let open = period.openTime?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let close = period.closeTime?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    guard !open.isEmpty, !close.isEmpty else { return nil }
                    if let day = period.openDay, !day.isEmpty {
                        return "\(day.capitalized) \(open) – \(close)"
                    }
                    return "Open \(open) – \(close)"
                }
                if !formatted.isEmpty { return formatted.joined(separator: "\n") }
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
            var built: [DealTerm] = []
            let validity = listDeal.validity.trimmingCharacters(in: .whitespacesAndNewlines)
            if !validity.isEmpty {
                let calendarText = validity.lowercased().hasPrefix("valid")
                    ? validity
                    : "Valid \(validity)"
                built.append(DealTerm(symbolName: "calendar", text: calendarText))
            }
            built.append(DealTerm(symbolName: "person", text: "DubaiVibe members only."))
            built.append(DealTerm(symbolName: "fork.knife", text: "Dine-in only"))
            built.append(DealTerm(symbolName: "nosign", text: "Cannot be combined with other offers"))
            terms = built
        } else {
            let icons = ["calendar", "person", "fork.knife", "nosign"]
            terms = termTexts.enumerated().map { index, text in
                DealTerm(symbolName: icons[index % icons.count], text: text)
            }
        }
        return VenueDetailDeal(
            badge: Deal.exclusiveBadge,
            discount: listDeal.discount,
            detail: listDeal.detail,
            terms: terms,
            ctaTitle: "Unlock Deal",
            offerId: coupon.id?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        )
    }
}

// MARK: - Favorite Toggle (`POST|DELETE /businesses/{uuid}/favorite`)

struct FavoriteToggleResponse: Decodable {
    let success: Bool?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case success, message
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
    }

    var isSuccessful: Bool { success != false }
}

// MARK: - Unlock Offer (`POST /businesses/offers/{offerId}/unlock`)

struct UnlockOfferResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: UnlockOfferData?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(UnlockOfferData.self, forKey: .data)
    }

    var resolvedData: UnlockOfferData? {
        guard success != false else { return nil }
        return data
    }
}

struct UnlockOfferData: Decodable {
    let redemptionId: String?
    let redemptionCode: String?
    let status: String?
    let redeemedAt: String?
    /// Short-lived code expiry from unlock (often ~15 minutes).
    let expiresAt: String?
    /// Deal / membership validity end (`validUntil` from unlock API).
    let validUntil: String?
    let validityMinutes: Int?
    let offer: UnlockOfferRef?
    let business: UnlockOfferBusinessRef?

    enum CodingKeys: String, CodingKey {
        case redemptionId, redemption_id
        case redemptionCode, redemption_code, code
        case status
        case redeemedAt, redeemed_at
        case expiresAt, expires_at
        case validUntil, valid_until
        case validityMinutes, validity_minutes
        case offer
        case business
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        redemptionId = values.decodeFlexibleIfPresent(forKey: .redemptionId)
            ?? values.decodeFlexibleIfPresent(forKey: .redemption_id)
        redemptionCode = values.decodeFlexibleIfPresent(forKey: .redemptionCode)
            ?? values.decodeFlexibleIfPresent(forKey: .redemption_code)
            ?? values.decodeFlexibleIfPresent(forKey: .code)
        status = values.decodeFlexibleIfPresent(forKey: .status)
        redeemedAt = values.decodeFlexibleIfPresent(forKey: .redeemedAt)
            ?? values.decodeFlexibleIfPresent(forKey: .redeemed_at)
        expiresAt = values.decodeFlexibleIfPresent(forKey: .expiresAt)
            ?? values.decodeFlexibleIfPresent(forKey: .expires_at)
        validUntil = values.decodeFlexibleIfPresent(forKey: .validUntil)
            ?? values.decodeFlexibleIfPresent(forKey: .valid_until)
        if let minutes: Int = values.decodeFlexibleIfPresent(forKey: .validityMinutes)
            ?? values.decodeFlexibleIfPresent(forKey: .validity_minutes) {
            validityMinutes = minutes
        } else {
            validityMinutes = nil
        }
        offer = try? values.decode(UnlockOfferRef.self, forKey: .offer)
        business = try? values.decode(UnlockOfferBusinessRef.self, forKey: .business)
    }

    var redeemedDate: Date {
        Self.parseISO8601(redeemedAt) ?? Date()
    }

    /// Prefer API `validUntil` for the membership "Valid Until" row.
    var validUntilDate: Date {
        if let parsed = Self.parseISO8601(validUntil) {
            return parsed
        }
        if let parsed = Self.parseISO8601(expiresAt) {
            return parsed
        }
        let minutes = max(validityMinutes ?? 15, 1)
        return redeemedDate.addingTimeInterval(TimeInterval(minutes * 60))
    }

    var expiresDate: Date {
        if let parsed = Self.parseISO8601(expiresAt) {
            return parsed
        }
        let minutes = max(validityMinutes ?? 15, 1)
        return redeemedDate.addingTimeInterval(TimeInterval(minutes * 60))
    }

    var resolvedCode: String {
        let code = redemptionCode?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return code
    }

    private static func parseISO8601(_ raw: String?) -> Date? {
        let value = raw?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !value.isEmpty else { return nil }
        if let date = isoFractional.date(from: value) { return date }
        return isoBasic.date(from: value)
    }

    private static let isoFractional: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoBasic: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

struct UnlockOfferRef: Decodable {
    let id: String?
    let title: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, title, name
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
            ?? values.decodeFlexibleIfPresent(forKey: .uuid)
        title = values.decodeFlexibleIfPresent(forKey: .title)
            ?? values.decodeFlexibleIfPresent(forKey: .name)
    }
}

struct UnlockOfferBusinessRef: Decodable {
    let id: String?
    let name: String?

    enum CodingKeys: String, CodingKey {
        case id, uuid, name, title
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
            ?? values.decodeFlexibleIfPresent(forKey: .uuid)
        name = values.decodeFlexibleIfPresent(forKey: .name)
            ?? values.decodeFlexibleIfPresent(forKey: .title)
    }
}

extension VenueCategory {
    static func matching(apiName: String?) -> VenueCategory? {
        let value = (apiName ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !value.isEmpty else { return nil }

        // Exact slug / title matches first (matches GET /categories order & icons).
        switch value {
        case "all":
            return .all
        case "restaurants", "restaurant":
            return .restaurants
        case "bars-lounges", "bars", "bars & lounges", "bar", "lounges":
            return .bars
        case "nightlife", "night life", "nightclub", "night club":
            return .nightlife
        case "cafes", "cafés", "cafe", "café":
            return .cafes
        case "brunches", "brunch":
            return .brunches
        case "beach-clubs", "beach clubs", "beachclub", "beach club":
            return .beachClubs
        case "ladies-nights", "ladies nights", "ladies-night", "ladies night":
            return .ladiesNights
        case "gyms-fitness", "gyms & fitness", "gyms", "fitness", "gym":
            return .gymsFitness
        case "padel-tennis", "padel & tennis", "padel", "tennis":
            return .padelTennis
        case "beauty-salons", "beauty & salons", "beauty", "salons", "salon":
            return .beautySalons
        default:
            break
        }

        // Fuzzy fallback — order matters (ladies before night, beach before club).
        if value.contains("ladies") { return .ladiesNights }
        if value.contains("beach") { return .beachClubs }
        if value.contains("restaurant") || value.contains("food") || value.contains("dining") {
            return .restaurants
        }
        if value.contains("bar") || value.contains("lounge") { return .bars }
        if value.contains("cafe") || value.contains("café") || value.contains("coffee") {
            return .cafes
        }
        if value.contains("brunch") { return .brunches }
        if value.contains("night") || value.contains("club") { return .nightlife }
        if value.contains("gym") || value.contains("fitness") { return .gymsFitness }
        if value.contains("padel") || value.contains("tennis") { return .padelTennis }
        if value.contains("beauty") || value.contains("salon") { return .beautySalons }
        return nil
    }

    static func from(apiName: String?) -> VenueCategory {
        matching(apiName: apiName) ?? .restaurants
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
