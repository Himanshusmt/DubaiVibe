import Foundation

// MARK: - Mobile Notifications (`GET /api/mobile/v1/notifications`)
// Docs: http://18.194.78.138:5000/docs#/Mobile%20Notifications

struct NotificationListResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: NotificationListData?

    enum CodingKeys: String, CodingKey {
        case success, message, data, items
        case nextCursor, next_cursor
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        if let nested = try? values.decode(NotificationListData.self, forKey: .data) {
            data = nested
        } else if let items = try? values.decode([AppNotification].self, forKey: .items) {
            let cursor: String? = values.decodeFlexibleIfPresent(forKey: .nextCursor)
                ?? values.decodeFlexibleIfPresent(forKey: .next_cursor)
            data = NotificationListData(items: items, nextCursor: cursor)
        } else {
            data = nil
        }
    }

    var items: [AppNotification] { data?.items ?? [] }
    var nextCursor: String? { data?.nextCursor }
}

struct NotificationListData: Decodable {
    let items: [AppNotification]
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case items, results, notifications
        case nextCursor, next_cursor
    }

    init(items: [AppNotification], nextCursor: String?) {
        self.items = items
        self.nextCursor = nextCursor
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        items = (try? values.decode([AppNotification].self, forKey: .items))
            ?? (try? values.decode([AppNotification].self, forKey: .results))
            ?? (try? values.decode([AppNotification].self, forKey: .notifications))
            ?? []
        nextCursor = values.decodeFlexibleIfPresent(forKey: .nextCursor)
            ?? values.decodeFlexibleIfPresent(forKey: .next_cursor)
    }
}

struct AppNotification: Decodable, Hashable {
    let id: String
    var title: String
    var body: String
    var read: Bool
    var createdAt: String?
    var type: String?
    var category: String?
    var badge: String?
    var ctaTitle: String?
    var actionURL: String?
    var featured: Bool

    enum CodingKeys: String, CodingKey {
        case id, uuid
        case title, name, subject
        case body, message, content, description, subtitle
        case read, isRead, is_read, unread
        case createdAt, created_at, created, timestamp, sentAt, sent_at
        case type, kind
        case category, tag, channel
        case badge, offerBadge, offer_badge, label
        case ctaTitle, cta, cta_title, actionTitle, action_title, actionLabel, action_label
        case actionURL, actionUrl, action_url, deepLink, deeplink, url, link
        case featured, isFeatured, is_featured, highlight, important
        case data, meta, metadata, payload
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let resolvedID = values.decodeFlexibleIfPresent(forKey: .id)
            ?? values.decodeFlexibleIfPresent(forKey: .uuid)
            ?? ""
        id = resolvedID

        title = values.decodeFlexibleIfPresent(forKey: .title)
            ?? values.decodeFlexibleIfPresent(forKey: .name)
            ?? values.decodeFlexibleIfPresent(forKey: .subject)
            ?? ""

        body = values.decodeFlexibleIfPresent(forKey: .body)
            ?? values.decodeFlexibleIfPresent(forKey: .message)
            ?? values.decodeFlexibleIfPresent(forKey: .content)
            ?? values.decodeFlexibleIfPresent(forKey: .description)
            ?? values.decodeFlexibleIfPresent(forKey: .subtitle)
            ?? ""

        if let readFlag: Bool = values.decodeFlexibleIfPresent(forKey: .read)
            ?? values.decodeFlexibleIfPresent(forKey: .isRead)
            ?? values.decodeFlexibleIfPresent(forKey: .is_read) {
            read = readFlag
        } else if let unread: Bool = values.decodeFlexibleIfPresent(forKey: .unread) {
            read = !unread
        } else {
            read = true
        }

        createdAt = values.decodeFlexibleIfPresent(forKey: .createdAt)
            ?? values.decodeFlexibleIfPresent(forKey: .created_at)
            ?? values.decodeFlexibleIfPresent(forKey: .created)
            ?? values.decodeFlexibleIfPresent(forKey: .timestamp)
            ?? values.decodeFlexibleIfPresent(forKey: .sentAt)
            ?? values.decodeFlexibleIfPresent(forKey: .sent_at)

        type = values.decodeFlexibleIfPresent(forKey: .type)
            ?? values.decodeFlexibleIfPresent(forKey: .kind)
        category = values.decodeFlexibleIfPresent(forKey: .category)
            ?? values.decodeFlexibleIfPresent(forKey: .tag)
            ?? values.decodeFlexibleIfPresent(forKey: .channel)

        badge = Self.firstString(in: values, keys: [.badge, .offerBadge, .offer_badge, .label])
        ctaTitle = Self.firstString(in: values, keys: [
            .ctaTitle, .cta, .cta_title, .actionTitle, .action_title, .actionLabel, .action_label
        ])
        actionURL = Self.firstString(in: values, keys: [
            .actionURL, .actionUrl, .action_url, .deepLink, .deeplink, .url, .link
        ])

        let featuredFlag: Bool? = values.decodeFlexibleIfPresent(forKey: .featured)
            ?? values.decodeFlexibleIfPresent(forKey: .isFeatured)
            ?? values.decodeFlexibleIfPresent(forKey: .is_featured)
            ?? values.decodeFlexibleIfPresent(forKey: .highlight)
            ?? values.decodeFlexibleIfPresent(forKey: .important)
        featured = featuredFlag ?? false

        if let nested = (try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .data))
            ?? (try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .meta))
            ?? (try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .metadata))
            ?? (try? values.nestedContainer(keyedBy: CodingKeys.self, forKey: .payload)) {
            if title.isEmpty {
                title = Self.firstString(in: nested, keys: [.title, .name]) ?? title
            }
            if body.isEmpty {
                body = Self.firstString(in: nested, keys: [.body, .message]) ?? body
            }
            if badge == nil {
                badge = Self.firstString(in: nested, keys: [.badge, .offerBadge, .label])
            }
            if ctaTitle == nil {
                ctaTitle = Self.firstString(in: nested, keys: [.ctaTitle, .cta, .actionTitle])
            }
            if actionURL == nil {
                actionURL = Self.firstString(in: nested, keys: [.actionURL, .deepLink, .url])
            }
            if category == nil {
                category = Self.firstString(in: nested, keys: [.category, .tag])
            }
        }
    }

    private static func firstString(
        in container: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) -> String? {
        for key in keys {
            if let value: String = container.decodeFlexibleIfPresent(forKey: key),
               !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return value
            }
        }
        return nil
    }

    var isUnread: Bool { !read }

    var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? L10n.notifications : trimmed
    }

    var displayBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var parsedDate: Date? {
        guard let raw = createdAt?.trimmingCharacters(in: .whitespacesAndNewlines), !raw.isEmpty else {
            return nil
        }
        if let date = Self.isoFractional.date(from: raw) { return date }
        if let date = Self.isoBasic.date(from: raw) { return date }
        if let seconds = Double(raw) {
            let value = seconds > 10_000_000_000 ? seconds / 1000 : seconds
            return Date(timeIntervalSince1970: value)
        }
        return nil
    }

    var metaLine: String {
        var parts: [String] = []
        if let date = parsedDate {
            parts.append(Self.relativeFormatter.localizedString(for: date, relativeTo: Date()))
        }
        let categoryText = (category ?? type)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !categoryText.isEmpty {
            parts.append(categoryText)
        }
        return parts.joined(separator: " • ")
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

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
}

// MARK: - Mark read (`POST /api/mobile/v1/notifications/{uuid}/read`)

struct NotificationReadResponse: Decodable {
    let success: Bool?
    let message: String?
    let data: NotificationReadData?

    enum CodingKeys: String, CodingKey {
        case success, message, data
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        success = values.decodeFlexibleIfPresent(forKey: .success)
        message = values.decodeFlexibleIfPresent(forKey: .message)
        data = try? values.decode(NotificationReadData.self, forKey: .data)
    }
}

struct NotificationReadData: Decodable {
    let id: String?
    let read: Bool?

    enum CodingKeys: String, CodingKey {
        case id, uuid
        case read, isRead, is_read
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = values.decodeFlexibleIfPresent(forKey: .id)
            ?? values.decodeFlexibleIfPresent(forKey: .uuid)
        read = values.decodeFlexibleIfPresent(forKey: .read)
            ?? values.decodeFlexibleIfPresent(forKey: .isRead)
            ?? values.decodeFlexibleIfPresent(forKey: .is_read)
    }
}
