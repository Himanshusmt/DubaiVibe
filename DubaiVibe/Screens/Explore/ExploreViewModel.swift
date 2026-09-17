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
    private var favoriteCancellables = Set<AnyCancellable>()
    private var saveCancellables = Set<AnyCancellable>()
    private var favoriteInFlight = Set<String>()
    private var saveInFlight = Set<String>()
    private var nextCursor: String?
    private var isPaging = false
    private var pagingFailed = false
    private var activeQuery = ""
    private let pageSize = 20

    var hasMore: Bool { nextCursor != nil && !(nextCursor ?? "").isEmpty }

    func venue(with id: UUID) -> Venue? {
        venues.first { $0.id == id }
    }

    /// Optimistic toggle: POST when favoriting, DELETE when unfavoriting. Rolls back on failure.
    func toggleFavorite(
        id: UUID,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        guard let index = venues.firstIndex(where: { $0.id == id }) else { return }
        let businessID = venues[index].resolvedBusinessID
        guard !businessID.isEmpty else {
            completion(.failure(.invalidURL))
            return
        }
        guard !favoriteInFlight.contains(businessID) else { return }

        let previous = venues[index].isFavorite
        let next = !previous
        venues[index].isFavorite = next
        favoriteInFlight.insert(businessID)

        BusinessAPI.setFavorite(uuid: businessID, isFavorite: next, showLoader: false)
            .sink { [weak self] completionResult in
                guard let self else { return }
                self.favoriteInFlight.remove(businessID)
                if case .failure(let error) = completionResult {
                    if let idx = self.venues.firstIndex(where: { $0.id == id }) {
                        self.venues[idx].isFavorite = previous
                    }
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] (response: FavoriteToggleResponse) in
                guard let self else { return }
                guard response.isSuccessful else {
                    if let idx = self.venues.firstIndex(where: { $0.id == id }) {
                        self.venues[idx].isFavorite = previous
                    }
                    let error = APIError.serverError(response.message ?? "Unable to update favorite.")
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            .store(in: &favoriteCancellables)
    }

    /// Optimistic toggle: POST when saving, DELETE when unsaving. Rolls back on failure.
    func toggleBookmark(
        id: UUID,
        completion: @escaping (Result<Void, APIError>) -> Void
    ) {
        guard let index = venues.firstIndex(where: { $0.id == id }) else { return }
        let businessID = venues[index].resolvedBusinessID
        guard !businessID.isEmpty else {
            completion(.failure(.invalidURL))
            return
        }
        guard !saveInFlight.contains(businessID) else { return }

        let previous = venues[index].isBookmarked
        let next = !previous
        venues[index].isBookmarked = next
        saveInFlight.insert(businessID)

        BusinessAPI.setSaved(uuid: businessID, isSaved: next, showLoader: false)
            .sink { [weak self] completionResult in
                guard let self else { return }
                self.saveInFlight.remove(businessID)
                if case .failure(let error) = completionResult {
                    if let idx = self.venues.firstIndex(where: { $0.id == id }) {
                        self.venues[idx].isBookmarked = previous
                    }
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            } receiveValue: { [weak self] (response: FavoriteToggleResponse) in
                guard let self else { return }
                guard response.isSuccessful else {
                    if let idx = self.venues.firstIndex(where: { $0.id == id }) {
                        self.venues[idx].isBookmarked = previous
                    }
                    let error = APIError.serverError(response.message ?? "Unable to update saved place.")
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                    return
                }
                completion(.success(()))
            }
            .store(in: &saveCancellables)
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

        let categoryId = selectedCategory.isAll ? nil : selectedCategory.id
        let cursor = reset ? nil : nextCursor
        let query = activeQuery.isEmpty ? nil : activeQuery

        LocationManager.shared.resolveCurrentCoordinate { [weak self] coordinate in
            guard let self else { return }
            BusinessAPI.listBusinesses(
                cursor: cursor,
                limit: self.pageSize,
                query: query,
                categoryId: categoryId,
                latitude: coordinate?.latitude,
                longitude: coordinate?.longitude,
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
                let next = response.nextCursor?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                self.nextCursor = next.isEmpty ? nil : next
                self.pagingFailed = false
                completion(.success(response))
            }
            .store(in: &self.feedCancellables)
        }
    }

    private func applyCategories(_ items: [CategoryItem]) {
        // Preserve API array order when sortOrder ties (backend currently sends the same
        // sortOrder for every category). Do not alphabetize — that mismatches icon/name order.
        let mapped = items
            .enumerated()
            .compactMap { index, item -> (index: Int, category: ExploreCategory)? in
                guard let category = item.asExploreCategory() else { return nil }
                return (index, category)
            }
            .sorted { lhs, rhs in
                if lhs.category.sortOrder == rhs.category.sortOrder {
                    return lhs.index < rhs.index
                }
                return lhs.category.sortOrder < rhs.category.sortOrder
            }
            .map(\.category)

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
