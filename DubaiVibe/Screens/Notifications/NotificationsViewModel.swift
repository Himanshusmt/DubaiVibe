import Combine
import Foundation
import UIKit

enum NotificationDaySection: Hashable {
    case today
    case yesterday
    case earlier(String)

    var title: String {
        switch self {
        case .today: return L10n.notificationsToday
        case .yesterday: return L10n.notificationsYesterday
        case .earlier(let label): return label
        }
    }
}

final class NotificationsViewModel {
    @Published private(set) var sections: [(section: NotificationDaySection, items: [AppNotification])] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""

    private var items: [AppNotification] = []
    private var cancellables = Set<AnyCancellable>()
    private var nextCursor: String?
    private var isPaging = false
    private let pageSize = 20

    var unreadCount: Int { items.filter(\.isUnread).count }
    var hasMore: Bool { !(nextCursor ?? "").isEmpty }
    var isEmpty: Bool { items.isEmpty }

    func load(showLoader: Bool = true, completion: ((Result<Void, APIError>) -> Void)? = nil) {
        nextCursor = nil
        isPaging = false
        cancellables.removeAll()
        fetch(reset: true, showLoader: showLoader, completion: completion)
    }

    func loadMoreIfNeeded(completion: ((Result<Void, APIError>) -> Void)? = nil) {
        guard hasMore, !isLoading, !isPaging else { return }
        fetch(reset: false, showLoader: false, completion: completion)
    }

    func item(at indexPath: IndexPath) -> AppNotification? {
        guard sections.indices.contains(indexPath.section),
              sections[indexPath.section].items.indices.contains(indexPath.row) else {
            return nil
        }
        return sections[indexPath.section].items[indexPath.row]
    }

    func markRead(id: String, completion: ((Result<Void, APIError>) -> Void)? = nil) {
        guard let index = items.firstIndex(where: { $0.id == id }), items[index].isUnread else {
            completion?(.success(()))
            return
        }

        items[index].read = true
        rebuildSections()

        NotificationsAPI.markRead(uuid: id, showLoader: false)
            .sink { [weak self] result in
                if case .failure(let error) = result {
                    self?.errorMessage = error.localizedDescription
                    if let idx = self?.items.firstIndex(where: { $0.id == id }) {
                        self?.items[idx].read = false
                        self?.rebuildSections()
                    }
                    completion?(.failure(error))
                }
            } receiveValue: { _ in
                completion?(.success(()))
            }
            .store(in: &cancellables)
    }

    private func fetch(
        reset: Bool,
        showLoader: Bool,
        completion: ((Result<Void, APIError>) -> Void)?
    ) {
        if reset {
            isLoading = true
        } else {
            isPaging = true
        }
        errorMessage = ""

        let cursor = reset ? nil : nextCursor
        NotificationsAPI.list(cursor: cursor, limit: pageSize, showLoader: showLoader)
            .sink { [weak self] result in
                guard let self else { return }
                self.isLoading = false
                self.isPaging = false
                if case .failure(let error) = result {
                    self.errorMessage = error.localizedDescription
                    completion?(.failure(error))
                }
            } receiveValue: { [weak self] (response: NotificationListResponse) in
                guard let self else { return }
                self.isLoading = false
                self.isPaging = false
                let page = response.items.filter { !$0.id.isEmpty }
                if reset {
                    self.items = page
                } else {
                    let existing = Set(self.items.map(\.id))
                    self.items.append(contentsOf: page.filter { !existing.contains($0.id) })
                }
                self.nextCursor = response.nextCursor
                self.rebuildSections()
                completion?(.success(()))
            }
            .store(in: &cancellables)
    }

    private func rebuildSections() {
        let calendar = Calendar.current
        let now = Date()
        var today: [AppNotification] = []
        var yesterday: [AppNotification] = []
        var earlierBuckets: [(key: String, date: Date, items: [AppNotification])] = []

        for item in items {
            let date = item.parsedDate ?? now
            if calendar.isDateInToday(date) {
                today.append(item)
            } else if calendar.isDateInYesterday(date) {
                yesterday.append(item)
            } else {
                let key = Self.dayKey.string(from: date)
                if let index = earlierBuckets.firstIndex(where: { $0.key == key }) {
                    earlierBuckets[index].items.append(item)
                } else {
                    earlierBuckets.append((key, date, [item]))
                }
            }
        }

        var built: [(NotificationDaySection, [AppNotification])] = []
        if !today.isEmpty { built.append((.today, today)) }
        if !yesterday.isEmpty { built.append((.yesterday, yesterday)) }
        for bucket in earlierBuckets {
            built.append((.earlier(bucket.key), bucket.items))
        }
        sections = built
    }

    private static let dayKey: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
