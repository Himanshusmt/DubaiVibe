import Combine
import CoreLocation
import Foundation

final class ExploreViewModel {
    @Published private(set) var venues: [Venue] = []
    @Published private(set) var categories: [ExploreCategory] = [.all]
    @Published private(set) var selectedCategory: ExploreCategory = .all
    @Published private(set) var isLoading = false
    @Published var errorMessage = ""

    private var feedCancellables = Set<AnyCancellable>()
    private var categoryCancellables = Set<AnyCancellable>()
    private var nextCursor: String?
    private var isPaging = false
    private var pagingFailed = false
    private var activeQuery = ""
    private let pageSize = 20

    var hasMore: Bool { nextCursor != nil && !(nextCursor ?? "").isEmpty }

    func venue(with id: UUID) -> Venue? {
        venues.first { $0.id == id }
    }

    func toggleFavorite(id: UUID) {
        guard let index = venues.firstIndex(where: { $0.id == id }) else { return }
        venues[index].isFavorite.toggle()
    }

    func toggleBookmark(id: UUID) {
        guard let index = venues.firstIndex(where: { $0.id == id }) else { return }
        venues[index].isBookmarked.toggle()
    }

    func loadCategories(
        showLoader: Bool = false,
        completion: @escaping (Result<CategoryListResponse, APIError>) -> Void
    ) {
        categoryCancellables.removeAll()
        BusinessAPI.listCategories(showLoader: showLoader)
            .sink { [weak self] completionResult in
                if case .failure(let error) = completionResult {
                    self?.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] (response: CategoryListResponse) in
                guard let self else { return }
                self.applyCategories(response.items)
                completion(.success(response))
            }
            .store(in: &categoryCancellables)
    }

    func loadFeed(
        showLoader: Bool = true,
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        activeQuery = ""
        fetch(reset: true, showLoader: showLoader, completion: completion)
    }

    func search(
        _ query: String,
        showLoader: Bool = true,
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        activeQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        fetch(reset: true, showLoader: showLoader, completion: completion)
    }

    func selectCategory(
        _ category: ExploreCategory,
        showLoader: Bool = false,
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        selectedCategory = category
        fetch(reset: true, showLoader: showLoader, completion: completion)
    }

    func loadMoreIfNeeded(
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        guard hasMore, !isLoading, !isPaging, !pagingFailed else { return }
        fetch(reset: false, showLoader: false, completion: completion)
    }

    private func fetch(
        reset: Bool,
        showLoader: Bool,
        completion: @escaping (Result<BusinessListResponse, APIError>) -> Void
    ) {
        if reset {
            nextCursor = nil
            isPaging = false
            pagingFailed = false
            feedCancellables.removeAll()
        } else {
            guard let cursor = nextCursor, !cursor.isEmpty else { return }
            isPaging = true
        }

        isLoading = reset
        errorMessage = ""

        let location = LocationManager.shared.lastKnownLocation?.coordinate
        let hasLocation = location != nil
        let categoryId = selectedCategory.isAll ? nil : selectedCategory.id

        BusinessAPI.listBusinesses(
            cursor: reset ? nil : nextCursor,
            limit: pageSize,
            query: activeQuery.isEmpty ? nil : activeQuery,
            categoryId: categoryId,
            latitude: hasLocation ? location?.latitude : nil,
            longitude: hasLocation ? location?.longitude : nil,
            showLoader: showLoader
        )
        .sink { [weak self] completionResult in
            self?.isLoading = false
            self?.isPaging = false
            if case .failure(let error) = completionResult {
                if !reset { self?.pagingFailed = true }
                self?.errorMessage = error.localizedDescription
                completion(.failure(error))
            }
        } receiveValue: { [weak self] (response: BusinessListResponse) in
            guard let self else { return }
            self.isLoading = false
            self.isPaging = false
            let incoming = response.items.compactMap { $0.asVenue() }
            self.merge(incoming, reset: reset)
            let cursor = response.nextCursor?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            self.nextCursor = cursor.isEmpty ? nil : cursor
            self.pagingFailed = false
            completion(.success(response))
        }
        .store(in: &feedCancellables)
    }

    private func applyCategories(_ items: [CategoryItem]) {
        let mapped = items
            .compactMap { $0.asExploreCategory() }
            .sorted { lhs, rhs in
                if lhs.sortOrder == rhs.sortOrder {
                    return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
                }
                return lhs.sortOrder < rhs.sortOrder
            }

        let hasAll = mapped.contains(where: \.isAll)
        categories = hasAll ? mapped : [.all] + mapped

        if let currentID = selectedCategory.id {
            if let match = categories.first(where: { $0.id == currentID }) {
                selectedCategory = match
            } else {
                selectedCategory = categories.first(where: \.isAll) ?? .all
            }
        } else if let match = categories.first(where: \.isAll) {
            selectedCategory = match
        } else {
            selectedCategory = categories.first ?? .all
        }
    }

    private func merge(_ incoming: [Venue], reset: Bool) {
        if reset {
            venues = incoming
            return
        }
        var seen = Set(venues.map(\.id))
        var extra: [Venue] = []
        extra.reserveCapacity(incoming.count)
        for venue in incoming where !seen.contains(venue.id) {
            seen.insert(venue.id)
            extra.append(venue)
        }
        venues.append(contentsOf: extra)
    }
}
